#!/bin/bash
# Every `sketchybar` invocation costs ~25ms of fixed overhead, so this builds
# one argument list and fires a single call. The add/remove-per-device version
# forked ~12 times and took ~300ms between click and popup.
#
# Devices are enumerated fresh because they genuinely come and go; the row COUNT
# is unbounded, which is the only case where add/remove beats pre-allocation.
source "$HOME/.config/sketchybar/colors.sh"
DRAW=toggle; [ "${1-}" = "--show" ] && DRAW=on
PLUGINS="$HOME/.config/sketchybar/plugins"

command -v SwitchAudioSource >/dev/null 2>&1 || { open -b com.apple.systempreferences; exit 0; }

ARGS=()
for it in $(sketchybar --query volume 2>/dev/null | jq -r '.popup.items[]?'); do
  ARGS+=(--remove "$it")
done

CUR=$(SwitchAudioSource -c 2>/dev/null)
i=0
while IFS= read -r dev; do
  [ -n "$dev" ] || continue
  i=$((i+1))
  if [ "$dev" = "$CUR" ]; then ic=""; col=$ACCENT; else ic=" "; col=$LABEL; fi
  ARGS+=(--add item volume.dev.$i popup.volume
         --set volume.dev.$i icon="$ic" icon.color=$col label="$dev" label.color=$col
               click_script="SwitchAudioSource -s '$dev'; sketchybar --set volume popup.drawing=off; sketchybar --trigger volume_change")
done < <(SwitchAudioSource -a -t output 2>/dev/null)

ARGS+=(--add item volume.mute popup.volume
       --set volume.mute icon="" label="Toggle mute"
             click_script="$PLUGINS/toggle_mute.sh; sketchybar --set volume popup.drawing=off"
       --add item volume.settings popup.volume
       --set volume.settings icon="" label="Sound settings"
             click_script="open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'; sketchybar --set volume popup.drawing=off"
       --set volume popup.drawing="$DRAW" --set clock popup.drawing=off --set battery popup.drawing=off)

sketchybar "${ARGS[@]}"
