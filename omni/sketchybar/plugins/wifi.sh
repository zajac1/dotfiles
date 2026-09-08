#!/bin/bash
# Wi-Fi, as signal strength rather than just on/off.
#
# RSSI comes from CoreWLAN (CWInterface.rssiValue) through JXA: ~65ms, no sudo
# and no extra tooling. The obvious candidates are all dead ends - `airport -I`
# was removed in macOS 14, `wdutil info` needs sudo, `ipconfig` has no RSSI,
# and `system_profiler SPAirPortDataType` has it but takes 3.1 SECONDS, which
# is why this looked impossible at first.
#
# The SSID stays empty unless Location Services is granted to SketchyBar:
# macOS 14+ gates the network name behind it (that is the "<redacted>" you get
# from ipconfig). RSSI is NOT gated, so the strength works regardless.
source "$HOME/.config/sketchybar/colors.sh"

read -r RSSI POWER <<< "$(osascript -l JavaScript -e '
ObjC.import("CoreWLAN");
var i = $.CWWiFiClient.sharedWiFiClient.interface;
i.isNil() ? "0 false" : i.rssiValue + " " + (i.powerOn ? "true" : "false")' 2>/dev/null)"
case "${RSSI:-0}" in ''|*[!0-9-]*) RSSI=0 ;; esac

SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F' SSID : ' '/ SSID :/ {print $2; exit}')
case "$SSID" in ""|"<redacted>") SSID="" ;; esac

if [ "$POWER" != true ] || ! ipconfig getifaddr en0 >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon="󰖪" icon.color=$DIM label=""
  exit 0
fi

# dBm bands. -30 is next to the router, -90 is unusable; the thresholds are the
# conventional ones and the colour follows the battery's rule: fine, low, bad.
if   [ "$RSSI" -ge -55 ]; then ICON="󰤨"; COL=$CYAN
elif [ "$RSSI" -ge -67 ]; then ICON="󰤥"; COL=$CYAN
elif [ "$RSSI" -ge -75 ]; then ICON="󰤢"; COL=$YELLOW
elif [ "$RSSI" -ge -85 ]; then ICON="󰤟"; COL=$YELLOW
else                           ICON="󰤫"; COL=$RED
fi

sketchybar --set "$NAME" icon="$ICON" icon.color=$COL label="$SSID"
