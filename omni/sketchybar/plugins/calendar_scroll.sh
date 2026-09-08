#!/bin/bash
# Scrolling the month header moves through months in either direction.
#
# A SketchyBar popup stacks vertically, so one row is one click target: the two
# arrows in "< September 2026 >" cannot be independently clickable. Clicking
# advances a month; scrolling is what goes back.
set -u
OFF="${1:-0}"
case "$OFF" in ''|*[!0-9-]*) OFF=0 ;; esac
D=$(printf '%.0f' "${SCROLL_DELTA:-0}")
[ "$D" -eq 0 ] && exit 0
if [ "$D" -gt 0 ]; then STEP=-1; else STEP=1; fi
exec "$HOME/.config/sketchybar/plugins/calendar_popup.sh" "$((OFF + STEP))"
