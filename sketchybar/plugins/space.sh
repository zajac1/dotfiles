#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"
CUR="${INFO:-}"
N="${NAME#space.}"
if [ "$N" = "$CUR" ]; then sketchybar --set "$NAME" label.color=$ACCENT
else sketchybar --set "$NAME" label.color=$DIM; fi
