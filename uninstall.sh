#!/bin/bash
# Removes omni's scripts, launch agents and caches. Leaves ~/.config/omni (your
# config, themes, favourites), ~/.config/sketchybar and ~/.aerospace.toml: those
# are yours to delete, and the bar/WM configs may be in use without omni.
set -u
for a in com.omni.launcher com.omni.wallpaper; do
  launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/$a.plist" 2>/dev/null
  rm -f "$HOME/Library/LaunchAgents/$a.plist"
done
pkill -f "ghostty .*--config-file=$HOME/.cache/omni/ghostty.conf" 2>/dev/null
rm -f "$HOME"/.local/bin/omni "$HOME"/.local/bin/omni-*
rm -rf "$HOME/.cache/omni"
echo "removed. Kept: ~/.config/omni, ~/.config/sketchybar, ~/.aerospace.toml, ~/.config/ghostty/omni-theme."
