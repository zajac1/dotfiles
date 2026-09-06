#!/bin/bash
# macOS exposes no public way to ask which Space you are on, so we only learn it
# when space_change fires. On load nothing has fired yet, which left every
# indicator unmarked. Remember the last known value so the marker is correct
# immediately after a reload, and self-corrects on the first switch.
source "$HOME/.config/sketchybar/colors.sh"
STATE="$HOME/.cache/omni/bar.space"

if [ -n "${INFO:-}" ]; then
  CUR="$INFO"
  mkdir -p "$(dirname "$STATE")"
  printf '%s' "$CUR" > "$STATE"
else
  CUR=$(cat "$STATE" 2>/dev/null)
  [ -n "$CUR" ] || CUR=1
fi

N="${NAME#space.}"
if [ "$N" = "$CUR" ]; then
  sketchybar --set "$NAME" label.color=$BAR_COLOR \
                           background.color=$ACCENT background.drawing=on \
                           background.corner_radius=6 background.height=18
else
  sketchybar --set "$NAME" label.color=$DIM background.drawing=off
fi
