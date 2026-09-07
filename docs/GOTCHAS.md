# Gotchas

Hard-won, in rough order of how much time each one cost.

## 1. A pty test harness lies about size

Rendering `omni` inside `pty.fork()` + `pyte` is genuinely useful — it shows the
exact cell grid, so you can assert "is the star present", "does Down skip the
spacer", "is there an ellipsis". Use it for **structure**.

It is wrong about **dimensions**. It under-reports fzf's chrome by about 6 rows.
Trusting it produced a menu that rendered 9 items in the harness and 3 on the
real screen. Anything dimensional must be calibrated against a screenshot of the
real Ghostty quick terminal.

## 2. The quick terminal is always 80x24

Ghostty 1.3.1 has no `quick-terminal-size`. `window-width` / `window-height` are
silently ignored for it. The only options are position, screen,
animation-duration, autohide, space-behavior, keyboard-interactivity.

That is the entire reason for `OMNI_FRAME="boxed"`: run at
`background-opacity = 0` so the window is invisible, and let `fzf --margin`
draw a correctly sized box inside it.

The cost is real: an opaque box, no blur. `OMNI_FRAME="full"` trades size
control back for translucency.

## 3. Transparent window means every background must be explicit

With `background-opacity = 0`, any cell fzf does not paint shows the desktop.
All eight background slots must be set: `bg`, `current-bg`, `input-bg`,
`list-bg`, `header-bg`, `selected-bg`, `preview-bg`, `gutter`.

Symptom of missing one: a YouTube video visible through the selected row.

## 4. Nerd Font glyphs are Ambiguous width

They live in the Private Use Area. Go's runewidth (which fzf uses) can resolve
Ambiguous as *wide*, counting every icon as 2 cells, so rows appear to overflow
and get truncated. `export RUNEWIDTH_EASTASIAN=0` in `omni` pins it.

Reproduce by setting it to `1`.

Related: macOS `awk` counts `length()` in **bytes**, not characters, regardless
of locale. A 3-byte glyph rendering as 1 cell breaks every padding calculation
that assumes otherwise.

## 5. fzf and Ghostty disagree about usable width

Not resolved. Padding to what looks like the exact available width still
produced a truncation ellipsis on the real screen while the harness showed none.
`--ellipsis=''` makes truncation invisible rather than correct. Combined with
"no right-aligned element anywhere", the symptom is gone.

If you add a right-aligned element, expect this to come back.

## 6. `set -o pipefail` + `grep -q` is a trap

`ps | grep -q pattern` — grep exits on first match, `ps` takes SIGPIPE (141),
and pipefail propagates that as failure. A running-instance guard written this
way never fires, and every call spawns another Ghostty, each registering the
same global hotkey. `omni-start` deliberately uses plain `set -u`.

## 7. Bash on macOS is 3.2

`${var//x/y}` works. `${var,,}` does not. Arrays work; `${arr[@]+"${arr[@]}"}`
is needed to expand a possibly-empty one under `set -u`.

And: **never** interpolate untrusted text into `$(( ))`. Bash recursively
evaluates a variable's *contents* as arithmetic, and array subscripts there
undergo command substitution — `x=1,x[$(touch /tmp/pwned)]` executes, and `set -u`
does not stop that form. A cache file read into `$(( ))` was a live RCE here.

## 8. fzf specifics

- `--filter` mode does **not** validate `--bind` expressions. A malformed bind
  passes the filter-mode check and then kills the real UI. Verify binds by
  dumping argv with a stub `fzf`, or by running it for real.
- Placeholders (`{}`, `{q}`, `{3}`) are shell-quoted by fzf, including inside
  pipelines. They are safe. `{}` yields the **whole** line, not the
  `--with-nth` projection.
- `transform` output is *actions*, and placeholders inside it are NOT
  re-expanded. That is why `omni-enter` writes to `~/.cache/omni/pending` and
  emits a bare `become(omni-exec)`.
- There is no such thing as a non-selectable row mid-list. `--header-lines=N`
  only covers the first N lines. Everything else needs the `omni-skip` trick.
- `--gap` is uniform. It cannot space one section only.
- `--gap` draws dotted separator lines by default; `--gap-line=` blanks them.
- An unquoted `$extra` containing `--bind=focus:transform(cmd {3} {n})` is split
  on spaces into three arguments. Use an array.

## 9. `set -e` plus a non-matching `grep` aborts silently

`omni-index` used `set -euo pipefail`. A cache lookup written as
`c=$(grep -F "$app" "$COLORS" ...)` exits non-zero when the cache is cold, and
`set -e` then killed the whole index build before `mv "$INDEX.tmp"` — leaving a
stale index and no error anywhere. It now uses plain `set -u`.

## 10. `grep -v` exits 1 when it prints nothing

```sh
grep -vxF "$path" "$FAVS" > "$FAVS.tmp" && mv "$FAVS.tmp" "$FAVS"   # BROKEN
```

Removing the **last** line means grep outputs nothing and exits 1, so the `&&`
never fires and the file is left unchanged. Unpinning your only favourite
silently did nothing. Same family as the `pipefail` trap above: a non-zero exit
that means "no matches", not "failure".

## 11. Security invariants

- The `kind` field must always be a literal in the `printf` **format** string.
  That is what stops a hostile `.app` filename from forging a row kind.
- `omni-exec`'s `run` case has no `*)` fallthrough. Keep it that way.
- Anything used to index a file that gets `.`-sourced must be validated against
  `*[!a-zA-Z0-9._-]*` — otherwise `../../` is code execution.
- `qalc` is a scripting language. `load()` reads arbitrary files; `(10^10)!`
  never returns. Both reachable by typing. Hence the whitelist and the perl
  alarm (macOS has no `timeout(1)`).

## 12. Startup sequencing

Hide the cursor (`ESC[?25l`) *before* the clear. Otherwise it sits at the grid
origin — eleven columns left of the visible box, over transparent background —
for ~80ms. About 16ms of that is fzf's own init and cannot be suppressed.

Do not add command substitutions to `omni-index`'s per-app loop. `$(printf | tr)`
per app is ~250 extra process spawns and made a cold launch 68% slower.

## 13. Long rows

`--ellipsis=''` hides truncation but does not prevent it, so an over-long row
just stops mid-word. `--wrap=word` is the general fix: rows break at a word
boundary onto a second line instead of disappearing. Keep labels short anyway -
"Search the web for X" cost 12 cells of chrome before anything useful.

Note wrapped rows occupy two terminal lines, so a list full of them fits fewer
items than `OMNI_CHROME` arithmetic assumes.

## 14. Icon colours

`sips` can render an `.icns` to a 16x16 32-bit BMP, and the dominant colour can
be read with `od` + `awk` — no Pillow, no ImageMagick.

Two traps: the BMP pixel-data offset is in bytes 10-13 and is **138** here, not
the textbook 54; and the 1x1 "average" is useless (Chrome averages to a muddy
tan). Pick the most *saturated* opaque pixel instead — that lands on the brand
colour.

Extraction costs ~3.7s for ~106 apps, so results are cached by path in
`~/.cache/omni/colors.tsv`.

## 15. Flat menu search excludes confirm levels

`omni-menu-query` flattens every level into one searchable list when the query
is non-empty. `confirm:*` levels are deliberately left out: their rows execute a
restart or shutdown the moment Enter lands, and a fuzzy match one keypress away
from that is too close. Typing "restart" surfaces the *menu* row that leads to
the confirmation screen, never the confirmation itself. Verified: "yes" matches
nothing but a web search.

## 16. `start` fires before the list exists

fzf's `start` event runs before any item is loaded, so both `{}` and `pos(N)`
are no-ops there. Anything that needs to inspect or move to a row must bind
`load` instead. This is why the menu kept opening with the cursor on the
Favorites title even though `start:pos(2)` was in the argv.

## 17. Ghostty config cannot be reloaded programmatically

`reload_config` exists only as a **keybind action** (default `super+shift+,`).
There is no CLI for it, and no signal: `SIGUSR1` terminates the process
(verified). Config is read at app start.

Consequence: anything that lives in the Ghostty config - the font, chiefly -
cannot be changed live. Colours escape this because they can be pushed into a
running terminal as OSC sequences; fonts have no equivalent. Applying a font
therefore has to restart the instance, which closes the launcher window.

## 18. Do not right-align anything

A filled section band has to be padded to an exact width, and fzf and Ghostty
disagree about what that width is (see 5). Padded to the edge it truncated;
after `--wrap` landed it wrapped into a stray coloured fragment on the next
line. The fix was to stop needing the width: the `FAVORITES` heading is a dim
label with no fill, and the pinned-item marker is appended after the text rather
than right-aligned. Only `--highlight-line` fills a row, and fzf sizes that.

## 19. An emitted move does not re-fire its own binding

`down:down+transform(omni-skip {} down)` skips ONE sep row. The `down` the
transform emits moves the cursor but does not re-run the `down` binding, so two
adjacent sep rows (a box cap followed by a spacer) left the cursor on the
second. omni-skip therefore emits `down+transform(omni-skip {} down N+1)` and
recurses, capped at 6 so a level made entirely of sep rows cannot loop.

## 20. A pipeline's left side is a subshell

```sh
if cond; then flag=1; else flag=0; fi | consumer   # flag never reaches consumer
```

Decide before the pipe, or re-test the condition on the right-hand side.

## 21. `--highlight-line` fills the whole row, not your box

fzf sizes the selection highlight itself, so it can never line up with a
narrower drawn box. The two are mutually exclusive: the menu draws a box and
selects with accent text, search has no box and uses the fill.

## 22. wttr.in serves HTML unless the UA looks like a terminal

`-A "omni"` returned an HTML page and the report window came up empty.
`-A "curl/8"` gets the ASCII rendering. (`?format=j1` returns JSON either way,
which is why the data path never showed the problem.)

## 23. Never guess a Nerd Font codepoint

Three icons shipped wrong because I mapped names to codepoints from memory:

| shipped | what it actually is |
|---|---|
| `U+F0750` "umbrella" | `md-microsoft_xbox_controller_battery_unknown` |
| `U+F0B22` "tshirt" | `md-bulldozer` |
| `U+F0E1C` "thermometer-low" | `md-car_off` |

Verifying a codepoint *exists* proves nothing about what it draws. Use
`omni-glyphs <name>`, which greps an index generated from the font's own cmap.

## 24. `awk length()` counts bytes — again

Centring the weather art measured 22 for a 14-character line, because `‘` is
three bytes, so the offset computed to zero and nothing moved. `wc -m` is
locale-aware and counts characters. This is the third distinct bug from this
one behaviour; assume `length()` is bytes everywhere in this codebase.

## 25. The skip cap must exceed the longest run of sep rows

`omni-skip` recurses with a depth cap so an all-sep level cannot loop. The cap
was 6; the Weather view has a run of **eight** sep rows (five art lines plus
three readings), so the cursor stopped inside the art. Raised to 40. Any new
informational view lengthens that run — check it against the cap.

## 26. The window edge cannot be removed on macOS

`background-opacity = 0` makes the window invisible, but a faint edge remains.
`macos-window-shadow = false` and `window-decoration = false` (the docs say
`false` is equivalent to `none`) are both set and do **not** remove it.

Per ghostty-org/ghostty discussion #9611 this is not fixable today: in AppKit
the shadow and the edge styling are the same property (`hasShadow`), so they
cannot be separated. A collaborator tried adding `.borderless` to the window
style mask and reported it "makes no difference". iTerm2 works around it by
removing the native window entirely and rebuilding the chrome by hand, which is
fragile across macOS releases.

Do not spend more time on this. Follow #9611.


## 27. "JetBrains Mono" is not "JetBrainsMono Nerd Font"

The bar rendered no icons at all because a font fallback resolved to plain
JetBrains Mono, which contains none of the Nerd Font glyphs. Worse, the guard
was `[ -n "$(fc-list | grep -i 'JetBrainsMono Nerd')" ] || FONT="JetBrains Mono"`
- fc-list *is* present on this machine (pulled in by a brew dependency), the
font was not, so the fallback fired silently. Never fall back to a font that
cannot render your glyphs; fail loudly instead.

## 28. SketchyBar centres between groups, not on screen

`position=center` places an item in the space left over between the left and
right groups. With an uneven right side it will not sit on the screen centre.
Balance it with a padding item if true centring matters.

## 29. SketchyBar measures a label trimmed, then draws it untrimmed

A popup label of 28 characters that begins with 7 spaces draws 21 and clips the
rest: the drawing width is computed from the whitespace-trimmed string, the
text is drawn from the untrimmed one. NBSP does not help - it is trimmed too.
The calendar lost its year and the last day of week one this way. No label may
begin with whitespace; centre with `label.align=center` over an explicit
`label.width`, never with padding characters. Trailing blanks are harmless.

## 30. `/bin/bash` is 3.2 and `printf '‹'` prints the text `‹`

`\u` escapes arrived in bash 4.2. Write glyphs and arrows as literal characters
(from Python, which does not strip them), never as escapes - and never as an
unquoted `ICON=\U000f0084`, where the shell eats the backslash first.

## 31. fzf `--gap` draws a dotted rule, whatever the help text implies

`--gap=1` renders `┈┈┈┈` between every item. `--gap-line=` (empty) keeps the
blank line and drops the rule. A terminal cannot draw half a line, so real
row padding is Ghostty's `adjust-cell-height` (`OMNI_ROW_PAD`), not `--gap`.

## 32. SketchyBar has no click-outside event

`mouse.exited.global` fires when the pointer leaves the bar; a click that does
not move the pointer away never fires anything. `front_app_switched` catches a
click into another app, not one into the app already in front. The model the
tool supports is hover-open / leave-close, which is what the bar uses. Upstream:
FelixKratz/SketchyBar#564, #613, #638.

## 33. With the menu bar auto-hidden, macOS reserves nothing at the top

`_HIHideMenuBar = 1` makes `visibleFrame == frame`. SketchyBar is an overlay
and reserves nothing either, so a floating bar draws over the top of every
window. Only a window manager with a top gap fixes that; shrinking the bar just
shrinks the overlap. Turning auto-hide off reserves ~25pt but shows the native
menu bar through the gap between the pills.

## 34. Wallpaper: strip overrides, restart the agent, THEN set

macOS 26 keeps a per-Space `Desktop` override in
`~/Library/Application Support/com.apple.wallpaper/Store/Index.plist` that
beats `SystemDefault`, and NSWorkspace only writes the current Space. Deleting
the overrides, restarting `WallpaperAgent`, then setting makes the agent
re-seed every live Space from the new default (and it garbage-collects the
stale Space records while it is at it - 45 went to 5). Doing it in the other
order - set, strip, restart - left the store in a "Linked" state with no
wallpaper anywhere. The order is load-bearing.

## 35. `shutil.copy2` off `/System` is refused

Copying a system wallpaper with `copy2` raises `Operation not permitted` on
the metadata step after the data has already been written, so the file exists
and the script has died. `copyfile` for anything under `/System`.

## 36. `set --` clobbers the argument you were about to use

`slot() { set -- $LIST; shift "$1"; }` shifts by the first word of LIST, not by
the number you passed - `set --` has already replaced `$1`. Save it first.
