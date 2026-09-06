#!/bin/bash
# Ctrl+<n> switches Spaces, but only if "Switch to Desktop N" is enabled in
# System Settings > Keyboard > Shortcuts > Mission Control. Needs Accessibility.
N="${1:-1}"
osascript -e "tell application \"System Events\" to key code $((17 + N)) using control down" 2>/dev/null
