#!/bin/bash
VOL="${INFO:-$(osascript -e "output volume of (get volume settings)")}"
if [ "$VOL" -eq 0 ]; then ICON=󰝟
elif [ "$VOL" -lt 34 ]; then ICON=󰕿
elif [ "$VOL" -lt 67 ]; then ICON=󰖀
else ICON=󰕾; fi
sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
