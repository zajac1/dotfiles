#!/bin/bash
PCT=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | tr -d "%")
CHG=$(pmset -g batt | grep -c "AC Power")
[ -z "$PCT" ] && exit 0
if [ "$CHG" -eq 1 ]; then ICON=󰂄
elif [ "$PCT" -ge 80 ]; then ICON=󰁹
elif [ "$PCT" -ge 50 ]; then ICON=󰂀
elif [ "$PCT" -ge 20 ]; then ICON=󰁽
else ICON=󰁻; fi
sketchybar --set "$NAME" icon="$ICON" label="${PCT}%"
