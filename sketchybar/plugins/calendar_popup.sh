#!/bin/bash
# Month grid with today marked, month navigation, and a way into the real
# calendar.
#
# $1 is a month offset: absent or 0 is this month and TOGGLES the popup (the
# bar click), anything else re-renders in place and leaves it open (the arrows).
#
# EVERY row uses the same font. Mixing Bold and Regular makes rows of identical
# character count lay out to different widths, which misaligns the columns.
# Emphasis is colour only. Row padding is U+00A0, see calendar_grid.py.
source "$HOME/.config/sketchybar/colors.sh"
PLUGINS="$HOME/.config/sketchybar/plugins"
SELF="$PLUGINS/calendar_popup.sh"

OFF="${1:-0}"
case "$OFF" in ''|*[!0-9-]*) OFF=0 ;; esac

MONO="JetBrainsMono Nerd Font:Regular:12.0"
ARGS=()
for it in $(sketchybar --query clock 2>/dev/null | jq -r '.popup.items[]?'); do
  ARGS+=(--remove "$it")
done

i=0
while IFS="$(printf '\t')" read -r kind text; do
  i=$((i+1))
  case "$kind" in
    head) col=$ACCENT ;;
    dow)  col=$DIM ;;
    now)  col=$ACCENT ;;
    *)    col=$LABEL ;;
  esac
  ARGS+=(--add item "clock.row$i" popup.clock
         --set "clock.row$i" icon.drawing=off label="$text" label.color="$col"
               label.font="$MONO" label.padding_left=12 label.padding_right=12)
done < <(python3 "$PLUGINS/calendar_grid.py" "$OFF")

nav() { # name icon label offset
  ARGS+=(--add item "clock.$1" popup.clock
         --set "clock.$1" icon="$2" icon.color=$ACCENT label="$3" label.color=$LABEL
               label.font="$MONO"
               icon.padding_left=12 icon.padding_right=8 label.padding_right=14
               click_script="$SELF $4")
}

nav prev "󰅁"  "Previous month" "$((OFF - 1))"
nav next "󰅂" "Next month"     "$((OFF + 1))"
[ "$OFF" -ne 0 ] && nav today "󰃶" "Back to today" "0"

# hey-calendar already has its own Ghostty instance with a global hotkey; spawning
# a second terminal for it just gets you an unstyled duplicate. Start the instance
# if it is not up, then press its hotkey (ctrl+alt+shift+cmd+C, key code 8 = "c").
# The keystroke needs Accessibility permission for SketchyBar.
ARGS+=(--add item clock.open popup.clock
       --set clock.open icon="󰃭" icon.color=$BLUE
             label="Open Calendar" label.color=$LABEL
             label.font="$MONO"
             icon.padding_left=12 icon.padding_right=8 label.padding_right=14
             click_script="$HOME/.local/bin/hey-calendar-start >/dev/null 2>&1; osascript -e 'tell application \"System Events\" to key code 8 using {control down, option down, shift down, command down}' >/dev/null 2>&1; sketchybar --set clock popup.drawing=off")

if [ "$OFF" -eq 0 ] && [ $# -eq 0 ]; then
  ARGS+=(--set clock popup.drawing=toggle)
else
  ARGS+=(--set clock popup.drawing=on)
fi

sketchybar "${ARGS[@]}"
