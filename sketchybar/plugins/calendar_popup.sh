#!/bin/bash
# Month grid with today marked, then a way into the real calendar.
#
# SketchyBar labels have no per-character colouring, so today cannot simply be
# recoloured inside a week row. Instead every day is rendered in a fixed FOUR
# character cell - " 07 " normally, "[07]" for today - which keeps the columns
# aligned whether today is a one or two digit number, and the week row that
# contains today is drawn in the accent colour.
source "$HOME/.config/sketchybar/colors.sh"

ARGS=()
for it in $(sketchybar --query clock 2>/dev/null | jq -r '.popup.items[]?'); do
  ARGS+=(--remove "$it")
done

# EVERY row uses the same font. Mixing Bold and Regular is the one thing that
# can make rows of identical character count lay out to different widths, which
# both misaligns the columns and inflates the popup. Emphasis is colour only.
MONO="JetBrainsMono Nerd Font:Regular:12.0"
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
done < <(python3 "$HOME/.config/sketchybar/plugins/calendar_grid.py")

ARGS+=(--add item clock.open popup.clock
       --set clock.open icon="󰃭" icon.color=$BLUE
             label="Open Calendar" label.color=$LABEL
             icon.padding_left=12 icon.padding_right=8 label.padding_right=12
             click_script="open -na Ghostty.app --args -e $HOME/.local/bin/hey-calendar; sketchybar --set clock popup.drawing=off"
       --set clock popup.drawing=toggle)

sketchybar "${ARGS[@]}"
