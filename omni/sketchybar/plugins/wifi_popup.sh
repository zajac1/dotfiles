#!/bin/bash
# Everything CoreWLAN will tell us without Location Services.
#
# The SSID and BSSID are the ONLY gated fields, and SketchyBar can never be
# granted that permission: Location is authorised per application bundle and
# sketchybar is a plain CLI binary run by launchd, so it is not eligible to
# appear in System Settings at all. Signal, noise, rate, channel and band are
# ungated - which is most of what you actually want to know.
source "$HOME/.config/sketchybar/colors.sh"
DRAW=toggle; [ "${1-}" = "--show" ] && DRAW=on

read -r RSSI NOISE RATE CH BAND <<< "$(osascript -l JavaScript -e '
ObjC.import("CoreWLAN");
var i = $.CWWiFiClient.sharedWiFiClient.interface, c = i.wlanChannel;
// TRAP: an ObjC enum through JXA does not === a JS number - c.channelBand
// compares false against 2 while "" + c.channelBand yields "2". Compare strings.
var b = c.isNil() ? "" : String(c.channelBand);
var band = b === "1" ? "2.4GHz" : b === "2" ? "5GHz" : b === "3" ? "6GHz" : "?";
[i.rssiValue, i.noiseMeasurement, i.transmitRate, c.isNil() ? "?" : c.channelNumber, band].join(" ")' 2>/dev/null)"
case "${RSSI:-0}" in ''|*[!0-9-]*) RSSI=0 ;; esac
case "${NOISE:-0}" in ''|*[!0-9-]*) NOISE=0 ;; esac
SNR=$(( RSSI - NOISE ))
IP=$(ipconfig getifaddr en0 2>/dev/null || echo "not connected")
GW=$(route -n get default 2>/dev/null | awk '/gateway:/ {print $2; exit}')

# quality wording from SNR, which is what actually predicts throughput
if   [ "$SNR" -ge 40 ]; then Q="excellent"; QC=$GREEN
elif [ "$SNR" -ge 25 ]; then Q="good";      QC=$GREEN
elif [ "$SNR" -ge 15 ]; then Q="fair";      QC=$YELLOW
else                         Q="poor";      QC=$RED
fi

ARGS=()
for it in $(sketchybar --query wifi 2>/dev/null | jq -r '.popup.items[]?'); do ARGS+=(--remove "$it"); done
MONO="JetBrainsMono Nerd Font:Regular:12.0"
row() { ARGS+=(--add item "wifi.$1" popup.wifi
       --set "wifi.$1" icon="$2" icon.color="$3" label="$4" label.color=$LABEL label.font="$MONO"
             icon.padding_left=12 icon.padding_right=8 label.padding_right=14); }

row signal  "󰘊"    "$QC"      "Signal        ${RSSI} dBm  $Q"
row snr     "󰑩" "$CYAN"    "Noise / SNR   ${NOISE} dBm  ${SNR} dB"
row rate    "󰓅"  "$BLUE"    "Link rate     ${RATE:-?} Mbps"
row chan    "󰀂" "$MAGENTA" "Channel       ${CH:-?}  ${BAND:-?}"
row ip      "󰩠"     "$YELLOW"  "Address       $IP"
[ -n "$GW" ] && row gw "󰩠" "$DIM" "Router        $GW"

ARGS+=(--add item wifi.settings popup.wifi
       --set wifi.settings icon="󰒓" icon.color=$DIM label="Wi-Fi settings" label.color=$LABEL
             label.font="$MONO" icon.padding_left=12 icon.padding_right=8 label.padding_right=14
             click_script="open 'x-apple.systempreferences:com.apple.wifi-settings-extension'; sketchybar --set wifi popup.drawing=off"
       --set wifi popup.drawing="$DRAW" --set clock popup.drawing=off --set battery popup.drawing=off --set volume popup.drawing=off)

sketchybar "${ARGS[@]}"
[ "$(sketchybar --query wifi | jq -r .popup.drawing)" = on ] && "$HOME/.config/sketchybar/plugins/popup_watch.sh" wifi >/dev/null 2>&1 &
