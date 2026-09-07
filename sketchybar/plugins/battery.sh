#!/bin/bash
# Icons carry the colour, labels stay neutral - the Rift rule.
#
# The glyphs are literal characters, not \U escapes: bash strips the backslash
# out of an unquoted ICON=\U000f0084 assignment and the bar renders the text
# "U000f0084".
source "$HOME/.config/sketchybar/colors.sh"
case "${SENDER:-}" in
  mouse.exited.global) sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
esac
PCT=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | tr -d "%")
CHG=$(pmset -g batt | grep -c "AC Power")
[ -z "$PCT" ] && exit 0
if   [ "$CHG" -eq 1 ];      then ICON=󰂄;  COL=$GREEN
elif [ "$PCT" -ge 80 ];     then ICON=󰁹; COL=$GREEN
elif [ "$PCT" -ge 50 ];     then ICON=󰂀; COL=$GREEN
elif [ "$PCT" -ge 20 ];     then ICON=󰁽;  COL=$YELLOW
else                             ICON=󰁻; COL=$RED; fi
sketchybar --set "$NAME" icon="$ICON" icon.color=$COL label="${PCT}%"
