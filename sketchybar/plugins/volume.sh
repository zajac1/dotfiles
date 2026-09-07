#!/bin/bash
case "$SENDER" in
  mouse.scrolled|mouse.exited.global|front_app_switched)
    exec "$HOME/.config/sketchybar/plugins/volume_scroll.sh" ;;
esac
VOL="${INFO:-$(osascript -e "output volume of (get volume settings)")}"
if [ "$VOL" -eq 0 ]; then ICON=󰝟
elif [ "$VOL" -lt 34 ]; then ICON=󰕿
elif [ "$VOL" -lt 67 ]; then ICON=󰖀
else ICON=󰕾; fi
sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
