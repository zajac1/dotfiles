#!/bin/bash
osascript -e "set volume output muted not (output muted of (get volume settings))" 2>/dev/null
sketchybar --trigger volume_change
