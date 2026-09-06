#!/bin/bash
# Removes omni. Leaves ~/.config/omni (your config, themes and favourites).
set -u
AGENT="$HOME/Library/LaunchAgents/com.omni.launcher.plist"
launchctl unload "$AGENT" 2>/dev/null
rm -f "$AGENT"
pkill -f "ghostty .*--config-file=$HOME/.cache/omni/ghostty.conf" 2>/dev/null
rm -f "$HOME"/.local/bin/omni "$HOME"/.local/bin/omni-*
rm -rf "$HOME/.cache/omni"
echo "removed. ~/.config/omni kept - delete it by hand if you want a clean slate."
