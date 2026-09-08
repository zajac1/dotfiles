#!/bin/bash
# There is no click-outside-to-dismiss in SketchyBar: the only auto-close is
# mouse.exited.global, which is deliberately popup-aware (moving from the bar
# INTO the popup does not fire it).
set -u
case "$SENDER" in
  mouse.exited.global|front_app_switched) sketchybar --set volume popup.drawing=off ;;
  mouse.scrolled)
    V=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
    D=$(printf '%.0f' "${SCROLL_DELTA:-0}")
    N=$(( V + (D > 0 ? 5 : -5) ))
    [ "$N" -gt 100 ] && N=100; [ "$N" -lt 0 ] && N=0
    osascript -e "set volume output volume $N" 2>/dev/null
    sketchybar --trigger volume_change ;;
esac
