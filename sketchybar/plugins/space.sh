#!/bin/bash
# space_change delivers $INFO as JSON - {"display-1": 3} - not a bare number.
# Comparing the raw blob to a space number never matched, so nothing ever
# painted. Parse it, and remember the value so a reload keeps the marker
# (macOS exposes no way to ask which Space is current).
#
# Rift gives every workspace its own colour rather than one accent for all;
# that is most of what makes the bar read as colourful. Inactive spaces wear
# their colour flat, the active one wears it as a filled pill.
source "$HOME/.config/sketchybar/colors.sh"
STATE="$HOME/.cache/omni/bar.space"

if [ -n "${INFO:-}" ]; then
  CUR=$(printf '%s' "$INFO" | jq -r 'if type=="object" then (to_entries[0].value|tostring) else tostring end' 2>/dev/null)
  [ -n "$CUR" ] && { mkdir -p "$(dirname "$STATE")"; printf '%s' "$CUR" > "$STATE"; }
else
  CUR=$(cat "$STATE" 2>/dev/null)
fi
[ -n "$CUR" ] && [ "$CUR" != "null" ] || CUR=1

N="${NAME#space.}"
PALETTE=($BLUE $MAGENTA $GREEN $YELLOW $CYAN $RED)
COL=${PALETTE[$(( (N - 1) % ${#PALETTE[@]} ))]}

# --animate applies to the NEXT --set, so it has to precede it on the same
# invocation. sin is the gentlest of SketchyBar's curves; 12 ticks is ~200ms.
if [ "$N" = "$CUR" ]; then
  sketchybar --animate sin 12 \
             --set "$NAME" label.color=$BAR_COLOR \
                           background.color=$COL background.drawing=on \
                           background.corner_radius=8 background.height=20
else
  sketchybar --animate sin 12 \
             --set "$NAME" label.color=$COL background.drawing=off
fi
