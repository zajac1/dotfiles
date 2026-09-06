#!/bin/bash
# Rebuild the output-device list, then toggle the popup.
#
# Devices are enumerated fresh on every open because they come and go (AirPods,
# monitors, docks). macOS has no built-in CLI for this - SwitchAudioSource is
# the only route.
source "$HOME/.config/sketchybar/colors.sh"
PLUGINS="$HOME/.config/sketchybar/plugins"

command -v SwitchAudioSource >/dev/null 2>&1 || { open -b com.apple.systempreferences; exit 0; }

# clear previous rows
for it in $(sketchybar --query volume 2>/dev/null | jq -r '.popup.items[]?'); do
  sketchybar --remove "$it" >/dev/null 2>&1
done

CUR=$(SwitchAudioSource -c 2>/dev/null)
i=0
SwitchAudioSource -a -t output 2>/dev/null | while IFS= read -r dev; do
  [ -n "$dev" ] || continue
  i=$((i+1))
  if [ "$dev" = "$CUR" ]; then ic=""; col=$ACCENT; else ic=" "; col=$LABEL; fi
  sketchybar --add item volume.dev.$i popup.volume \
             --set volume.dev.$i icon="$ic" icon.color=$col label="$dev" \
                                 label.color=$col \
                                 click_script="SwitchAudioSource -s '$dev'; sketchybar --set volume popup.drawing=off; sketchybar --trigger volume_change"
done

sketchybar --add item volume.mute popup.volume \
           --set volume.mute icon="" label="Toggle mute" \
                 click_script="$PLUGINS/toggle_mute.sh; sketchybar --set volume popup.drawing=off"
sketchybar --add item volume.settings popup.volume \
           --set volume.settings icon="" label="Sound settings" \
                 click_script="open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'; sketchybar --set volume popup.drawing=off"

sketchybar --set volume popup.drawing=toggle
