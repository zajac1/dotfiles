#!/bin/bash
# omni installer. Idempotent: never overwrites an existing config.sh or
# favorites file. Run from anywhere.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Components. The launcher is always installed; the rest are optional and
# default to "if the tool is there":
#   launcher   the menu + search, themes, glyphs            (always)
#   terminal   Ghostty theme file wiring                     (always; harmless)
#   editor     Neovim colorscheme generated from the theme   (always; harmless)
#   wallpaper  theme-driven desktop pictures + rotation      (default on)
#   bar        SketchyBar top bar                            (default: if sketchybar is installed)
#   wm         AeroSpace config with the bar gap             (default: if AeroSpace is installed)
#
#   ./install.sh                           everything applicable
#   ./install.sh --profile work            launcher + terminal + editor only
#   ./install.sh --without bar,wallpaper   opt out of specific pieces
#   ./install.sh --with wm                 force a piece on
#   ./install.sh --no-start                install but do not start the launcher
WANT_BAR=auto; WANT_WM=auto; WANT_WALLPAPER=1; NO_START=0
setc() { # name value
  case "$1" in
    bar) WANT_BAR=$2 ;; wm) WANT_WM=$2 ;; wallpaper) WANT_WALLPAPER=$2 ;;
    launcher|terminal|editor) [ "$2" = 1 ] || echo "    note: $1 is always installed" ;;
    *) echo "unknown component: $1 (launcher terminal editor wallpaper bar wm)" >&2; exit 2 ;;
  esac
}
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) shift; case "${1-}" in
        work) WANT_BAR=0; WANT_WM=0; WANT_WALLPAPER=0 ;;
        home) WANT_BAR=1; WANT_WM=1; WANT_WALLPAPER=1 ;;
        *) echo "usage: --profile work|home" >&2; exit 2 ;; esac ;;
    --with)    shift; for c in $(printf '%s' "${1-}" | tr ',' ' '); do setc "$c" 1; done ;;
    --without) shift; for c in $(printf '%s' "${1-}" | tr ',' ' '); do setc "$c" 0; done ;;
    --no-bar)   WANT_BAR=0 ;;
    --no-start) NO_START=1 ;;
    *) echo "usage: install.sh [--profile work|home] [--with a,b] [--without a,b] [--no-start]" >&2; exit 2 ;;
  esac
  shift
done
[ "$WANT_BAR" = auto ] && { command -v sketchybar >/dev/null 2>&1 && WANT_BAR=1 || WANT_BAR=0; }
[ "$WANT_WM" = auto ]  && { { command -v aerospace >/dev/null 2>&1 || [ -d /Applications/AeroSpace.app ]; } && WANT_WM=1 || WANT_WM=0; }
echo "==> components: launcher terminal editor$([ "$WANT_WALLPAPER" = 1 ] && printf ' wallpaper')$([ "$WANT_BAR" = 1 ] && printf ' bar')$([ "$WANT_WM" = 1 ] && printf ' wm')"
BIN="$HOME/.local/bin"
CFG="$HOME/.config/omni"
BAR="$HOME/.config/sketchybar"
AGENT="$HOME/Library/LaunchAgents/com.omni.launcher.plist"

echo "==> checking dependencies"
missing=()
command -v fzf  >/dev/null || missing+=("fzf")
command -v qalc >/dev/null || missing+=("libqalculate")
command -v jq   >/dev/null || missing+=("jq")
command -v btop >/dev/null || echo "    note: btop not found - Utilities CPU/Memory/Network need it"
command -v nowplaying-cli >/dev/null || echo "    note: nowplaying-cli not found - the bar's Now Playing item stays blank"
command -v python3 >/dev/null || missing+=("python3 (xcode-select --install)")
command -v magick >/dev/null || echo "    note: imagemagick not found - gradient wallpapers fall back to a plainer renderer (brew install imagemagick)"
[ -d /Applications/Ghostty.app ] || missing+=("ghostty (cask)")
if [ ${#missing[@]} -gt 0 ]; then
  echo "    missing: ${missing[*]}"
  echo "    brew install fzf libqalculate jq && brew install --cask ghostty"
  echo "    fonts:   brew install --cask font-caskaydia-mono-nerd-font"
  exit 1
fi
echo "    ok"

echo "==> installing scripts to $BIN"
mkdir -p "$BIN"
for f in "$SRC"/bin/omni*; do
  case "$f" in *omni-wallpaper*) [ "$WANT_WALLPAPER" = 1 ] || continue ;; esac
  install -m 0755 "$f" "$BIN/"
done
[ "$WANT_WALLPAPER" = 1 ] || rm -f "$BIN"/omni-wallpaper*

echo "==> installing config to $CFG"
# One directory per theme holding colors.toml (omarchy's format). An existing
# colors.toml is never overwritten - it is the user's to edit. Backgrounds are
# not shipped; `omni-theme-import` fetches them from omarchy on demand.
mkdir -p "$CFG/themes"
for d in "$SRC"/config/themes/*/; do
  n="$(basename "$d")"; mkdir -p "$CFG/themes/$n/backgrounds"
  [ -f "$CFG/themes/$n/colors.toml" ] || cp "$d/colors.toml" "$CFG/themes/$n/colors.toml"
done
"$BIN/omni-theme-build" --all
if [ -f "$CFG/config.sh" ]; then
  echo "    config.sh exists, left untouched"
else
  cp "$SRC/config/config.sh" "$CFG/config.sh"
  [ "$WANT_WALLPAPER" = 1 ] || sed -i '' 's/^OMNI_WALLPAPER=1/OMNI_WALLPAPER=0/; s/^OMNI_WALLPAPER_ROTATE=.*/OMNI_WALLPAPER_ROTATE=0/' "$CFG/config.sh"
  echo "    config.sh created"
fi
[ -f "$CFG/favorites" ] || : > "$CFG/favorites"
[ -f "$CFG/glyphs" ] || cp "$SRC/config/glyphs.example" "$CFG/glyphs"
[ -f "$CFG/sections" ] || cp "$SRC/config/sections.example" "$CFG/sections"
cp "$SRC/data/glyphs.tsv" "$CFG/glyphs.tsv"

echo "==> installing top bar to $BAR"
if [ "$WANT_BAR" != 1 ]; then
  echo "    skipped"
elif command -v sketchybar >/dev/null 2>&1; then
  mkdir -p "$BAR/plugins"
  install -m 0755 "$SRC"/sketchybar/sketchybarrc "$BAR/sketchybarrc"
  install -m 0755 "$SRC"/sketchybar/plugins/*    "$BAR/plugins/"
  # colors.sh is generated from the active palette, not shipped
  "$BIN/omni-bar-theme" >/dev/null 2>&1 || true
  echo "    ok (brew services start sketchybar, if it is not running)"
else
  echo "    sketchybar not installed, skipping - brew install FelixKratz/formulae/sketchybar"
fi

echo "==> AeroSpace config (optional)"
if [ "$WANT_WM" != 1 ]; then
  echo "    skipped"
elif [ -f "$HOME/.aerospace.toml" ]; then
  echo "    ~/.aerospace.toml exists, left untouched"
elif command -v aerospace >/dev/null 2>&1 || [ -d /Applications/AeroSpace.app ]; then
  cp "$SRC/config/aerospace.toml" "$HOME/.aerospace.toml"; echo "    ~/.aerospace.toml created (top gap for the bar)"
else
  echo "    AeroSpace not installed, skipping - brew install --cask nikitabobko/tap/aerospace"
fi

echo "==> Neovim colorscheme"
"$BIN/omni-nvim-theme" >/dev/null 2>&1 && echo "    ~/.cache/omni/nvim/colors/omni.lua generated" || echo "    (needs a theme; generated on first omni-theme)"
echo "    lazy.nvim spec: $SRC/config/nvim-omni.lua -> copy into your plugins directory"

echo "==> Ghostty terminal theme (optional)"
echo "    add this line to ~/.config/ghostty/config to theme all your terminals:"
echo "        config-file = omni-theme"

echo "==> launch agent"
mkdir -p "$(dirname "$AGENT")"
cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.omni.launcher</string>
  <key>ProgramArguments</key><array><string>$BIN/omni-start</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><false/>
</dict>
</plist>
PLIST
echo "    written (NOT loaded). To start at login:"
echo "        launchctl load $AGENT"

if [ "$NO_START" = 1 ]; then
  echo "==> skipping start (--no-start)"
else
  echo "==> starting"
  "$BIN/omni-start" --restart >/dev/null
fi
echo
echo "Done. Press Alt+Space."
echo "PATH note: $BIN must be on your PATH for the scripts to find each other."
