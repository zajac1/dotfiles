#!/bin/bash
# Rift spells the date out - "8th of May 12:50:50"; the "of" is dropped here.
# Seconds are deliberately
# dropped: they would need update_freq=1, and every sketchybar call costs
# ~25ms, so that is a fork per second forever for a digit nobody reads.
# The item subscribes to mouse.exited.global purely to dismiss its popup;
# SketchyBar has no click-outside-to-close of its own.
case "${SENDER:-}" in
  mouse.entered) exec "$HOME/.config/sketchybar/plugins/calendar_popup.sh" --show ;;
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
sketchybar --set "$NAME" label="$(date "+${D}${S} %B %H:%M")"
