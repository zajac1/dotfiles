#!/bin/bash
# Icons carry the colour, labels stay neutral - the Rift rule.
#
# The glyphs are literal characters, not \U escapes: bash strips the backslash
# out of an unquoted ICON=\U000f0084 assignment and the bar renders the text
# "U000f0084".
source "$HOME/.config/sketchybar/colors.sh"
case "${SENDER:-}" in
  mouse.entered)
    [ "$(sketchybar --query "$NAME" | jq -r '.popup.drawing')" = on ] && exit 0
    exec "$HOME/.config/sketchybar/plugins/battery_popup.sh" --show ;;
  mouse.exited.global|front_app_switched)
    sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
esac
PCT=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | tr -d "%")
CHG=$(pmset -g batt | grep -c "AC Power")
[ -z "$PCT" ] && exit 0

# Font Awesome's battery glyphs are HORIZONTAL, like the macOS one; the
# Material Design set omni uses elsewhere is vertical and reads worse at bar
# size. There is no horizontal charging glyph in the set, so charging shows a
# bolt before the level - which is what macOS does too.
if   [ "$PCT" -ge 88 ]; then ICON=""
elif [ "$PCT" -ge 63 ]; then ICON=""
elif [ "$PCT" -ge 38 ]; then ICON=""
elif [ "$PCT" -ge 13 ]; then ICON=""
else                         ICON=""; fi

if [ "$CHG" -eq 1 ]; then COL=$GREEN; ICON="󱐋$ICON"
elif [ "$PCT" -ge 50 ]; then COL=$GREEN
elif [ "$PCT" -ge 20 ]; then COL=$YELLOW
else COL=$RED; fi

sketchybar --set "$NAME" icon="$ICON" icon.color=$COL label="${PCT}%"
