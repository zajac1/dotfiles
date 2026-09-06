#!/bin/bash
SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F" SSID : " "/ SSID :/ {print \$2; exit}")
if [ -n "$SSID" ]; then sketchybar --set "$NAME" icon=󰖩 label="$SSID"
else sketchybar --set "$NAME" icon=󰖪 label="off"; fi
