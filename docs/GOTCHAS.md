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
