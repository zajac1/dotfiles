#!/bin/bash
SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F' SSID : ' '/ SSID :/ {print $2; exit}')
case "$SSID" in ""|"<redacted>") SSID="" ;; esac
if ipconfig getifaddr en0 >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon=󰖩 label="$SSID"
else
  sketchybar --set "$NAME" icon=󰖪 label=""
fi
