#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"
CUR="${INFO:-}"
N="${NAME#space.}"
if [ "$N" = "$CUR" ]; then
  sketchybar --set "$NAME" label.color=$BAR_COLOR \
                           background.color=$ACCENT background.drawing=on \
                           background.corner_radius=6 background.height=18
else
  sketchybar --set "$NAME" label.color=$DIM background.drawing=off
fi
