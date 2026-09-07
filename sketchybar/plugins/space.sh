#!/bin/bash
# Paint the workspace indicators.
#
# Two sources, chosen at runtime so the same bar works on a machine without a
# window manager:
#   - AeroSpace installed: its workspaces. AeroSpace tells the bar via
#     exec-on-workspace-change (custom event aerospace_workspace_change with
#     FOCUSED_WORKSPACE in the environment); on a reload we ask it directly.
#   - otherwise: macOS Spaces. space_change delivers $INFO as JSON -
#     {"display-1": 3} - not a bare number; parse it and remember it, since
#     macOS has no way to ask which Space is current.
#
# Rift gives every workspace its own colour rather than one accent for all;
# that is most of what makes the bar read as colourful. Inactive spaces wear
# their colour flat, the active one wears it as a filled pill.
source "$HOME/.config/sketchybar/colors.sh"
STATE="$HOME/.cache/omni/bar.space"
for p in /opt/homebrew/bin /usr/local/bin; do [ -d "$p" ] && PATH="$p:$PATH"; done; export PATH

if command -v aerospace >/dev/null 2>&1; then
  if [ -n "${FOCUSED_WORKSPACE:-}" ]; then CUR="$FOCUSED_WORKSPACE"
  else CUR=$(aerospace list-workspaces --focused 2>/dev/null | head -1); fi
elif [ -n "${INFO:-}" ]; then
  CUR=$(printf '%s' "$INFO" | jq -r 'if type=="object" then (to_entries[0].value|tostring) else tostring end' 2>/dev/null)
fi
if [ -n "${CUR:-}" ] && [ "$CUR" != "null" ]; then
  mkdir -p "$(dirname "$STATE")"; printf '%s' "$CUR" > "$STATE"
else
  CUR=$(cat "$STATE" 2>/dev/null); CUR="${CUR:-1}"
fi

N="${NAME#space.}"
PALETTE=($BLUE $MAGENTA $GREEN $YELLOW $CYAN $RED)
COL=${PALETTE[$(( (N - 1) % ${#PALETTE[@]} ))]}

# The cursor is one shared item (see sketchybarrc); every space item runs this
# script on the event, so only the item whose number is now current moves it -
# the others just recolour their own label. Offsets: CELL points per number.
CELL=23; SPACES="${OMNI_BAR_SPACES:-5}"; ROW=$(( CELL * SPACES ))
if [ "$N" = "$CUR" ]; then
  sketchybar --animate sin 20 \
             --set space.cursor background.padding_left=$(( CELL * (N - 1) )) \
                                background.padding_right=$(( ROW - CELL * N )) \
                                background.color=$COL \
             --animate sin 20 \
             --set "$NAME" label.color=$BAR_COLOR
else
  sketchybar --animate sin 20 --set "$NAME" label.color=$COL
fi
