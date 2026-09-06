#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"
CUR="${INFO:-}"
[ -z "$CUR" ] && CUR=$(sketchybar --query space_state 2>/dev/null | jq -r '.label.value' 2>/dev/null)
N="${NAME#space.}"
if [ "$N" = "$CUR" ]; then
  sketchybar --set "$NAME" label.color=$BAR_COLOR background.color=$ACCENT background.drawing=on
else
  sketchybar --set "$NAME" label.color=$DIM background.drawing=off
fi
