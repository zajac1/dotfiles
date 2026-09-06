#!/bin/bash
# load average, not instantaneous CPU%: `top -l 1` costs 947ms and this costs 24ms
read -r L _ _ < <(sysctl -n vm.loadavg | tr -d '{}')
C=$(sysctl -n hw.ncpu)
sketchybar --set "$NAME" label="$(awk -v l="$L" -v c="$C" 'BEGIN{printf "%.0f%%", (l/c)*100}')"
