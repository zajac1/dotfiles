#!/bin/bash
C="$HOME/.cache/omni/weather.json"
[ -s "$C" ] || exit 0
T=$(jq -r ".current_condition[0].temp_C" "$C" 2>/dev/null)
[ -n "$T" ] && [ "$T" != "null" ] && sketchybar --set "$NAME" label="${T}°C"
