#!/bin/bash
# One sketchybar invocation, not one per row: each call costs ~25ms of fixed
# overhead and this popup has six rows.
#
# Health is NominalChargeCapacity/DesignCapacity, which is what System Settings
# shows. ioreg's own "MaxCapacity" key is a service-threshold percentage pinned
# at 100 on healthy and unhealthy batteries alike - it is not health.
#
# The top-level keys are matched with spaces around "=" on purpose: the nested
# BatteryData blob repeats CycleCount and DesignCapacity without them.
source "$HOME/.config/sketchybar/colors.sh"
DRAW=toggle; [ "${1-}" = "--show" ] && DRAW=on

IO=$(ioreg -rn AppleSmartBattery 2>/dev/null)
key() { printf '%s' "$IO" | sed -n "s/.*\"$1\" = \([0-9-]*\).*/\1/p" | head -1; }

CYCLES=$(key CycleCount)
DESIGN=$(key DesignCapacity)
NOMINAL=$(key NominalChargeCapacity)
TEMP=$(key Temperature)

BATT=$(pmset -g batt)
PCT=$(printf '%s' "$BATT" | grep -Eo "[0-9]+%" | head -1)
REMAIN=$(printf '%s' "$BATT" | sed -n 's/.*; \([0-9]*:[0-9]*\) remaining.*/\1/p')
if printf '%s' "$BATT" | grep -q "AC Power"; then
  STATUS="Charging"; SICON="󰚥"; SCOL=$GREEN
else
  STATUS="On battery"; SICON="󰂄"; SCOL=$YELLOW
fi
[ -n "$REMAIN" ] && STATUS="$STATUS  $REMAIN left"

if [ -n "$NOMINAL" ] && [ -n "$DESIGN" ] && [ "$DESIGN" -gt 0 ] 2>/dev/null; then
  HEALTH=$(awk -v n="$NOMINAL" -v d="$DESIGN" 'BEGIN{printf "%d", (n/d)*100}')
  if [ "$HEALTH" -ge 80 ]; then HCOL=$GREEN; else HCOL=$YELLOW; fi
  HEALTH="$HEALTH%"
else
  HEALTH="unknown"; HCOL=$DIM
fi

ARGS=()
for it in $(sketchybar --query battery 2>/dev/null | jq -r '.popup.items[]?'); do
  ARGS+=(--remove "$it")
done

row() { # name icon colour label
  ARGS+=(--add item "battery.$1" popup.battery
         --set "battery.$1" icon="$2" icon.color="$3"
               label="$4" label.color=$LABEL
               label.font="JetBrainsMono Nerd Font:Regular:12.0"
               icon.padding_left=12 icon.padding_right=8 label.padding_right=14)
}

row status "$SICON"     "$SCOL"    "$STATUS"
row level  "󰁹" "$BLUE"    "Charge         $PCT"
row health "󰗶" "$HCOL"    "Health         $HEALTH"
row cycles "󰜉" "$CYAN"    "Cycles         ${CYCLES:-?}"
[ -n "$TEMP" ] && row temp "󰔏" "$MAGENTA" \
  "Temperature    $(awk -v t="$TEMP" 'BEGIN{printf "%.0f°C", t/100}')"

ARGS+=(--add item battery.settings popup.battery
       --set battery.settings icon="󰒓" icon.color=$DIM
             label="Battery settings" label.color=$LABEL
             label.font="JetBrainsMono Nerd Font:Regular:12.0"
             icon.padding_left=12 icon.padding_right=8 label.padding_right=14
             click_script="open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'; sketchybar --set battery popup.drawing=off"
       --set battery popup.drawing="$DRAW" --set clock popup.drawing=off --set volume popup.drawing=off)

sketchybar "${ARGS[@]}"
