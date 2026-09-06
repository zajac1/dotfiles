#!/bin/bash
# omni installer. Idempotent: never overwrites an existing config.sh or
# favorites file. Run from anywhere.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
CFG="$HOME/.config/omni"
AGENT="$HOME/Library/LaunchAgents/com.omni.launcher.plist"

echo "==> checking dependencies"
missing=()
command -v fzf  >/dev/null || missing+=("fzf")
command -v qalc >/dev/null || missing+=("libqalculate")
command -v jq   >/dev/null || missing+=("jq")
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
mkdir -p "$CFG/palettes" "$CFG/themes"
cp "$SRC"/config/palettes/*.toml "$CFG/palettes/"
cp "$SRC"/config/themes/*.sh     "$CFG/themes/"
if [ -f "$CFG/config.sh" ]; then
  echo "    config.sh exists, left untouched"
else
  cp "$SRC/config/config.sh" "$CFG/config.sh"
  echo "    config.sh created"
fi
[ -f "$CFG/favorites" ] || : > "$CFG/favorites"
[ -f "$CFG/glyphs" ] || cp "$SRC/config/glyphs.example" "$CFG/glyphs"

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

if [ "${1-}" = "--no-start" ]; then
  echo "==> skipping start (--no-start)"
else
  echo "==> starting"
  "$BIN/omni-start" --restart >/dev/null
fi
echo
echo "Done. Press Alt+Space."
echo "PATH note: $BIN must be on your PATH for the scripts to find each other."
