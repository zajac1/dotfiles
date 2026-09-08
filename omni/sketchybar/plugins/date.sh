#!/bin/bash
# "Thu 8th Sep" - weekday, the ordinal day the Rift bar spells out, and the
# month abbreviated so the pair of items stays short.
#
# This item carries the calendar popup; the clock beside it is just the time.
case "${SENDER:-}" in
  mouse.entered)
    [ "$(sketchybar --query "$NAME" | jq -r '.popup.drawing')" = on ] && exit 0
    exec "$HOME/.config/sketchybar/plugins/calendar_popup.sh" --show ;;
  mouse.exited.global|front_app_switched)
    sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
esac

D=$(date +%-d)
case "$D" in
  1|21|31) S=st ;;
  2|22)    S=nd ;;
  3|23)    S=rd ;;
  *)       S=th ;;
esac
sketchybar --set "$NAME" label="$(date "+%a ${D}${S} %b")"
