#!/bin/bash
case "$SENDER" in
  mouse.entered)
    [ "$(sketchybar --query "$NAME" | jq -r '.popup.drawing')" = on ] && exit 0
    exec "$HOME/.config/sketchybar/plugins/volume_popup.sh" --show ;;
  mouse.scrolled|mouse.exited.global|front_app_switched)
    exec "$HOME/.config/sketchybar/plugins/volume_scroll.sh" ;;
esac
VOL="${INFO:-$(osascript -e "output volume of (get volume settings)")}"
if [ "$VOL" -eq 0 ]; then ICON=󰝟
elif [ "$VOL" -lt 34 ]; then ICON=󰕿
elif [ "$VOL" -lt 67 ]; then ICON=󰖀
else ICON=󰕾; fi
sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
