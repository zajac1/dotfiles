#!/bin/bash
# Open the calendar. On the machine that has a hey-calendar Ghostty instance
# with a global hotkey, start it if needed and press the hotkey (ctrl+alt+shift+
# cmd+C, key code 8 = "c"; needs Accessibility permission for SketchyBar).
# Anywhere else, Calendar.app - so the bar package works on a machine that has
# never heard of hey.
sketchybar --set clock popup.drawing=off
if [ -x "$HOME/.local/bin/hey-calendar-start" ]; then
  "$HOME/.local/bin/hey-calendar-start" >/dev/null 2>&1
  osascript -e 'tell application "System Events" to key code 8 using {control down, option down, shift down, command down}' >/dev/null 2>&1
else
  open -a Calendar
fi
