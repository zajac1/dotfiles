#!/bin/bash
# Ctrl+<n> switches Spaces, but only if "Switch to Desktop N" is enabled in
# System Settings > Keyboard > Shortcuts > Mission Control. Those are OFF by
# default and the keystroke is silently dropped until they are on.
#
# macOS number-row key codes are not sequential - 5 is 23 and 6 is 22.
N="${1:-1}"
case "$N" in
  1) K=18 ;; 2) K=19 ;; 3) K=20 ;; 4) K=21 ;; 5) K=23 ;;
  6) K=22 ;; 7) K=26 ;; 8) K=28 ;; 9) K=25 ;; *) exit 0 ;;
esac
osascript -e "tell application \"System Events\" to key code $K using control down" 2>/dev/null
