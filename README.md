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

## Other machines

The launcher does not need the bar, a window manager or custom wallpapers; it
is meant to run alone on a work machine.

```sh
git clone <this repo> ~/git/omni
cd ~/git/omni
./install.sh --no-bar        # launcher only
./install.sh                 # launcher + top bar, if sketchybar is installed
```

`install.sh` never overwrites an existing `config.sh`, `favorites`, `sections`
or `glyphs`, so re-running it after a `git pull` is the upgrade path. Things
that differ per machine live in `~/.config/omni/config.sh`: the font, the
hotkey, `OMNI_PROJECT_ROOT`, and `OMNI_BAR_SPACES` for the bar. Nothing under
`~/.config/omni/` is tracked here.

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

A theme is one directory, in omarchy's own layout:

```
~/.config/omni/themes/<name>/
    colors.toml      the only file that matters - omarchy's format, unchanged
    backgrounds/     wallpapers; the theme switch sets one
```

Everything else is derived from `colors.toml` by `omni-theme-build` into
`~/.cache/omni/themes/<name>.sh` (the launcher's 10 colour roles), the bar's
`colors.sh`, and Ghostty's `omni-theme` file. Edit the toml, run the build -
or just switch to the theme, which builds it.

```sh
omni-theme                          # list, active marked
omni-theme tokyo-night              # switch: colours, bar, Ghostty, wallpaper, launcher
omni-theme-import                   # pull all of omarchy's themes + backgrounds (~60 MB)
omni-theme-propose photo.jpg        # a palette from a picture; --write makes it a theme
omni-wallpaper next                 # cycle the active theme's backgrounds
```

22 themes ship (colours only); backgrounds come from `omni-theme-import`.
`omni-theme-propose` derives the roles rather than sampling them - a picture
supplies a tint, an accent and up to six hues, then lightness and contrast are
enforced so text stays readable on any picture. Light mode is detected and can
be forced with `--light` / `--dark`.

A theme can say how its pictures are placed, in `themes/<name>/wallpaper.toml`:

```toml
placement = "gradient"   # fill | fit | center | stretch | gradient   (default: fill)
fill = "#ededed"         # colour around the image for fit/center (default: the theme background)
scale = "0.86"           # gradient only: the picture's height as a fraction of the screen's
```

`gradient` is for prints and posters: the picture is rendered onto a
screen-sized canvas whose margins continue the picture's own edges - each edge
strip averaged to a line and stretched outward, so the paper's tone and shading
carry on past the print instead of stopping at a flat colour. macOS cannot do
this itself; `omni-wallpaper-render` builds the canvas with `sips` and AppKit
(no dependencies) and caches it under `~/.cache/omni/wallpapers/`.

`OMNI_WALLPAPER_PLACEMENT` in `config.sh` sets the default for themes without
one. `omni-theme-propose` writes a `center` override itself when every picture
is far from the screen's shape - a square print would otherwise lose half of
itself to the default crop.

Wallpaper reaches **every** Space, not just the current one. macOS keeps a
per-Space override that beats the default; `omni-wallpaper` clears those,
restarts `WallpaperAgent` and then sets, which re-seeds all Spaces. Set
`OMNI_WALLPAPER_ALL_SPACES=0` to get the plain current-Space behaviour.

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

Utilities → Weather is the compact view — wttr.in's ASCII art for the current
condition, then the three things you actually act on:

```
     _`/"".-.
      ,\_(   ).
       /(___(__)

  󰸜  15°C · feels 10°C
  󰝐  15h 18% · 18h 15% · 21h 19%
  󰖝  26 km/h WNW
```

The temperature icon keys off **feels-like** — that is what you dress for.
Every remaining 3-hour slot is listed rather than just the peak: rain starting
earlier at a slightly lower chance is exactly what a peak figure hides.

*Full report* opens everything else in its own window — today's range, expected
precipitation, gusts, cloud, humidity, UV, visibility, pressure, sunrise/sunset,
and tomorrow. *Refresh* re-fetches without leaving the menu.

Icons are configurable if any render badly in your font:

```sh
OMNI_ICON_COLD=  OMNI_ICON_COOL=  OMNI_ICON_WARM=  OMNI_ICON_HOT=
OMNI_ICON_RAIN=  OMNI_ICON_WIND=
```

Cached for 15 minutes. A stale cache renders immediately and refreshes in the
background, so the menu never blocks on the network; only a cold cache fetches
synchronously. Live rows are deliberately excluded from the flat menu search —
otherwise every keystroke at the top level would hit the network.

| key | meaning |
|---|---|
| `OMNI_WEATHER_LOCATION` | empty = wttr.in IP geolocation; or `"Warsaw"` / `"50.06,19.94"` |
| `OMNI_WEATHER_TTL` | cache seconds, default 900 |

### Utilities

| entry | what it does |
|---|---|
| Weather | compact view; see below |
| CPU / Memory / Network | live readings, with *Open in btop* one keypress away |
| System Monitor | full `btop` |
| Caffeinate | placeholder |

btop cannot be shown *inside* the menu — it is a full-screen TUI with no
one-shot mode, and fzf renders text rows. So each submenu shows a cheap
snapshot (load, memory pressure, network throughput) and hands off to btop for
the real thing. Cost drove the choice of commands: `top -l 1 -n 0` takes 947 ms
and `ps -A -o %cpu` 573 ms, both far too slow for a menu render, so CPU uses
load average from `sysctl` (24 ms) and memory uses `vm_stat` (27 ms). Network
throughput is a delta between two `netstat -ib` samples, so rates appear from
the second visit onward.

The per-box btop views copy **your** `~/.config/btop/btop.conf` and override only
`shown_boxes`, so your theme and update rate carry over. btop has no CLI switch
for that key, and its numbered presets would fight whatever you have configured.

### Glyphs

```sh
omni-glyphs umbrella     # every umbrella in the font, with codepoints
omni-glyphs tshirt
```

Nerd Font codepoints are **not** guessable. `U+F0750` is not an umbrella, it is
`md-microsoft_xbox_controller_battery_unknown`; `U+F0B22` is a bulldozer. The
index in `data/glyphs.tsv` is generated from the font's own cmap — look glyphs
up there rather than trusting memory.

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

## Window manager

Nothing on macOS reserves screen space for a floating bar except the native
menu bar, so with it auto-hidden windows slide under the pills. AeroSpace
fixes that with `gaps.outer.top`; `config/aerospace.toml` is the config the bar
expects (arrow-key bindings, so alt+letter diacritics keep working; alt-space
left free for the launcher). The bar shows AeroSpace workspaces when it is
installed and macOS Spaces otherwise. AeroSpace needs Accessibility permission
on first launch.

Wallpapers rotate through the active theme's backgrounds every
`OMNI_WALLPAPER_ROTATE` seconds (launchd timer, `omni-wallpaper rotate on|off`;
0 disables). Style -> Next wallpaper skips ahead.

## Top bar

SketchyBar, modelled on omarchy's waybar — flat, icon-led, clock centred.

```
󰀵 1 2 3 4 5              Sun 18:28              󰂀 75%  󰍛 58%  󰕾 81%  󰖩
```

`omni-bar-theme` regenerates its colours from the active palette and reloads it;
`omni-theme` calls it, so launcher, terminal and bar re-theme together.

Clicking the volume icon opens a device popup (needs `switchaudio-osx`).

**Permissions macOS requires, none of which can be granted from a script:**

| what | where | needed for |
|---|---|---|
| hide the native menu bar | Control Centre → Menu Bar → Automatically hide → Always | seeing the bar at all |
| Accessibility for `sketchybar` | Privacy & Security → Accessibility → **+** | Space switching, logo → launcher |
| Switch to Desktop 1…5 | Keyboard → Shortcuts → Mission Control | Space switching |
| Location Services (optional) | Privacy & Security → Location Services | showing the Wi-Fi name; macOS returns `<redacted>` without it |

sketchybar will not appear in the Accessibility list on its own — it is a CLI
started by launchd and never triggers a prompt. Add it with **+**, then
Cmd+Shift+G and `/opt/homebrew/bin/sketchybar`.
