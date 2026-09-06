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
  Setup, Capture, Update, System.
- **Search** — reached from *Apps*. Fuzzy app and project search, with prefixes:

  | prefix | mode |
  |---|---|
  | *(none)* | apps + project directories |
  | `=` | calculator (`=100 EUR to PLN`, `=2 GiB to MB`, `=150 to hex`) |
  | `@` | web search |
  | `.` | file search (Spotlight, plus a bounded `find` for dotfiles) |

Numbers with an operator trigger the calculator without a prefix, so `2+2` just
works.

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
| `Ctrl+P` | pin / unpin the highlighted app |
| `↑ ↓` / `Ctrl+K` `Ctrl+J` | move (spacers are skipped) |

## Theming

19 palettes lifted from omarchy, converted through omarchy's own colour-role
mapping (`@border = @foreground`, `@selected-text = @accent`).

```sh
omni-theme              # list, active marked
omni-theme tokyo-night  # switch
```

Style → Theme in the menu previews **live** as you arrow through the list, and
reverts on `Esc`. Preview never writes to disk, so backing out is free.

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
| `OMNI_PROJECT_ROOT` | directory scanned for project entries |

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
