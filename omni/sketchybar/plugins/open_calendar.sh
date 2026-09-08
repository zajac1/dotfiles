#!/bin/bash
# Open the calendar - through omni's provider dispatcher, so the bar, the
# launcher and the global hotkey all agree on what "calendar" means. Falls
# back to Calendar.app on a machine with no provider installed.
sketchybar --set clock popup.drawing=off
for d in "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin; do [ -d "$d" ] && PATH="$d:$PATH"; done
export PATH
if command -v omni-calendar >/dev/null 2>&1 && omni-calendar; then
  exit 0
fi
open -a Calendar
