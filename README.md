# omni

An omarchy-style launcher and menu for macOS, built from `fzf` running inside a
transparent Ghostty quick terminal. Keyboard-driven, themeable, and small enough
to read in one sitting.

It does **not** replace Raycast. It sits on its own hotkey alongside it.

```
 ╭──────────────────────────────────────╮
 │                                      │
 │   ╭──────────────────────────────╮   │
 │   │ Go…                          │   │
 │   ╰──────────────────────────────╯   │
 │    Favorites                        │   <- dimmed-accent band, not selectable
 │    Ghostty                          │
 │                                      │   <- spacer, arrow keys skip it
 │    Apps                             │
 │    Style                            │
 │    Setup                            │
 │    Capture                          │
 │    Update                           │
 │    System                           │
 ╰──────────────────────────────────────╯
```

## What it is

Two surfaces on one hotkey, mirroring how omarchy splits them:

- **Menu** (`Alt+Space`) — pinned favourites plus categories: Apps, Style,
  Setup, Capture, Utilities, Update, System.
- **Search** — reached from *Apps*. Fuzzy app and project search, with prefixes:

  | prefix | mode |
  |---|---|
  | *(none)* | apps + project directories |
  | `=` | calculator (`=100 EUR to PLN`, `=2 GiB to MB`, `=150 to hex`) |
  | `@` | web search — `OMNI_SEARCH_URL`, Google by default. macOS exposes no way to ask the default browser for its configured engine, so this is ours to set. |
  | `.` | file search (Spotlight, plus a bounded `find` for dotfiles) |

Typing in the menu searches **every level of the menu tree at once** — `sl`
finds *Sleep*, `wifi` finds *Wifi*, `nord` finds the theme — so you rarely have
to drill. Apps are excluded from that (use *Apps*), and so are the confirmation
screens, since their rows restart or shut down immediately.

Numbers with an operator trigger the calculator without a prefix, so `2+2` just
works — **and the menu prompt accepts the same input**, so `Alt+Space` then
`2+2` answers immediately without going through Apps.

## Install

```sh
git clone <this repo> ~/git/omni
cd ~/git/omni && ./install.sh
```

Requires `fzf`, `libqalculate`, `jq`, Ghostty, and CaskaydiaMono Nerd Font:

```sh
brew install fzf libqalculate jq
brew install --cask ghostty font-caskaydia-mono-nerd-font
```

`~/.local/bin` must be on your `PATH`.

## Keys

| key | action |
|---|---|
| `Alt+Space` | open / close |
| `Enter` | run, or descend into a submenu |
| `Esc` | back one level, then close |
| `Ctrl+P` | pin / unpin the highlighted row (apps *or* menu actions) |
| `Shift+↑` `Shift+↓` | reorder a favourite |
| `↑ ↓` / `Ctrl+K` `Ctrl+J` | move (spacers are skipped) |

## Theming

19 palettes lifted from omarchy, converted through omarchy's own colour-role
mapping (`@border = @foreground`, `@selected-text = @accent`).

```sh
omni-theme              # list, active marked
omni-theme tokyo-night  # switch
```

Style → Theme previews **live** as you arrow through the list, and reverts on
`Esc`. Preview never writes to disk, so backing out is free.

Style → Font lists the monospace families Ghostty can see. **Applying one closes
the launcher**, and there is no way around it: the font lives in Ghostty's
config, which can only be reloaded by a keybind (no CLI, no signal). Colours
escape this because they can be pushed into a running terminal as OSC sequences.
The instance restarts in the background, so the next `Alt+Space` is already in
the new font. For the same reason fonts cannot preview live the way themes do. Fonts are
deliberately left out of the flat menu search — half of them contain the words
"Mono" or "Nerd" and would match almost anything.

Theme switching also writes `~/.config/ghostty/omni-theme`, a real Ghostty theme
file with all 16 palette colours. Add `config-file = omni-theme` to
`~/.config/ghostty/config` to theme every terminal you open. Set
`OMNI_THEME_TERMINALS=true` to also retint already-open terminals live, via OSC.

## Configuration

Everything lives in `~/.config/omni/config.sh`. The values worth knowing:

| key | meaning |
|---|---|
| `OMNI_THEME` | active palette |
| `OMNI_MENU_COLS` / `OMNI_COLS` | menu and search widths, in columns |
| `OMNI_CHROME` | rows fzf spends on borders/padding — **measured, see docs** |
| `OMNI_FRAME` | `boxed` (exact size, opaque) or `full` (translucent + blur) |
| `OMNI_HOTKEY` | Ghostty global keybind |
| `OMNI_SEARCH_URL` | search engine prefix (Google by default) |
| `OMNI_PROJECT_ROOT` | directory scanned for project entries |
| `OMNI_APP_COLORS` | tint each app glyph with its icon's dominant colour |

### Favourites

`Ctrl+P` pins whatever is highlighted — an app, or a menu action like *Sleep*.
Pinned entries appear under a `FAVORITES` heading at the top of the menu, and
carry a ★ in their own section so you can see what is pinned. `Shift+↑/↓`
reorders them; the file order in `~/.config/omni/favorites` is the display
order, so you can also just edit it.

omarchy has no equivalent — I checked both the quattro menu (336 entries, no
`section`/`group`/`header` keys) and the v3 Walker CSS. This is ours, so the
heading is drawn as an open bracket with the label on the top rule:

```
╭─ Favorites ─────────╮
│   Ghostty          │
│   Sleep            │
╰─────────────────────╯
```

The box is drawn at a deliberately conservative width rather than spanning the
full interior — see GOTCHAS 5 for why chasing the exact width is a trap.
`OMNI_FILL_INSET` controls it.

### Weather

Utilities → Weather reads [wttr.in](https://github.com/chubin/wttr.in)'s `j1`
JSON: current temperature and feels-like, conditions, and per-3-hour chances of
rain, snow and thunder plus wind gusts — only for the hours **left today**, and
only when a chance clears its threshold, so it stays a few short lines.

*Full report* opens wttr.in's ASCII rendering in a window.

Cached for 15 minutes. A stale cache renders immediately and refreshes in the
background, so the menu never blocks on the network; only a cold cache fetches
synchronously. Live rows are deliberately excluded from the flat menu search —
otherwise every keystroke at the top level would hit the network.

| key | meaning |
|---|---|
| `OMNI_WEATHER_LOCATION` | empty = wttr.in IP geolocation; or `"Warsaw"` / `"50.06,19.94"` |
| `OMNI_WEATHER_TTL` | cache seconds, default 900 |

### Menu sections

`~/.config/omni/sections` lists the root entries, one id per line. Comment one
out to hide it, reorder the lines to reorder the menu:

```
apps
style
setup
# capture      <- hidden, and dropped from search too
utilities
update
system
```

Hiding a section also removes its entries from the flat search, so a hidden
*Capture* takes *Screenshot* with it.

### Icons

Each app's glyph is tinted with the dominant colour extracted from its real
`.icns`, using only `sips`, `od` and `awk`. Colours are cached in
`~/.cache/omni/colors.tsv`, so only newly installed apps pay the cost.

Override any glyph in `~/.config/omni/glyphs`:

```
*slack*   = 
*figma*   = 
```

Real per-row icon *images* are not possible: fzf owns the screen and repaints
every row as text on each keystroke. Ghostty does support the Kitty graphics
protocol, but fzf offers no hook to anchor an image to a list row. Its only
image-capable surface is `--preview`.

Run `omni-start --restart` after changing anything.

## Fidelity to omarchy

Modelled on omarchy v3 (Walker, `--width 644` launcher / `--width 295` menu),
with the row treatment and rounded corners of omarchy 4. Colours, selection
style, prompt text and glyph-per-entry come from omarchy's own config and CSS.

What a terminal cannot reproduce: real app icons (fzf cannot draw images in list
rows), true 2px borders, sub-cell padding, per-pixel corner radius.

## Before you change anything

Read [`docs/GOTCHAS.md`](docs/GOTCHAS.md). This looks like ordinary shell but
several values are empirical, and there is a class of bug here that a test
harness will actively lie to you about.
