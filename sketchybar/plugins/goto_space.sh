#!/bin/bash
# Switch workspace N. With AeroSpace that is one command. Without it, Ctrl+<n>
# switches macOS Spaces - but only if "Switch to Desktop N" is enabled in
# System Settings > Keyboard > Shortcuts > Mission Control (off by default,
# and the keystroke is silently dropped until it is on).
#
# macOS number-row key codes are not sequential - 5 is 23 and 6 is 22.
N="${1:-1}"
for p in /opt/homebrew/bin /usr/local/bin; do [ -d "$p" ] && PATH="$p:$PATH"; done; export PATH
if command -v aerospace >/dev/null 2>&1; then
  exec aerospace workspace "$N"
fi
case "$N" in
  1) K=18 ;; 2) K=19 ;; 3) K=20 ;; 4) K=21 ;; 5) K=23 ;;
  6) K=22 ;; 7) K=26 ;; 8) K=28 ;; 9) K=25 ;; *) exit 0 ;;
esac
osascript -e "tell application \"System Events\" to key code $K using control down" 2>/dev/null
