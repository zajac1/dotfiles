#!/bin/bash
# omni installer. Idempotent: never overwrites an existing config.sh or
# favorites file. Run from anywhere.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --no-bar    launcher only; for a machine where you do not want the top bar
# --no-start  install but do not start the launcher
NO_BAR=0; NO_START=0
for arg in "$@"; do
  case "$arg" in
    --no-bar)   NO_BAR=1 ;;
    --no-start) NO_START=1 ;;
    *) echo "usage: install.sh [--no-bar] [--no-start]" >&2; exit 2 ;;
  esac
done
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
install -m 0755 "$SRC"/bin/omni* "$BIN/"

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
  echo "    config.sh created"
fi
[ -f "$CFG/favorites" ] || : > "$CFG/favorites"
[ -f "$CFG/glyphs" ] || cp "$SRC/config/glyphs.example" "$CFG/glyphs"
[ -f "$CFG/sections" ] || cp "$SRC/config/sections.example" "$CFG/sections"
cp "$SRC/data/glyphs.tsv" "$CFG/glyphs.tsv"

echo "==> installing top bar to $BAR"
if [ "$NO_BAR" = 1 ]; then
  echo "    skipped (--no-bar)"
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
