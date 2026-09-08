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

SHOW=0
[ "${1-}" = "--show" ] && { SHOW=1; shift; }
OFF="${1:-0}"
case "$OFF" in ''|*[!0-9-]*) OFF=0 ;; esac

MONO="JetBrainsMono Nerd Font:Regular:12.0"
GRID_W=188          # 26 chars of JetBrainsMono at 12pt, in points
# Literal characters, not printf '\\u2039': /bin/bash is 3.2 on macOS and \\u
# escapes arrived in 4.2, so that printf emits the text "\\u2039" verbatim.
LARROW='‹'
RARROW='›'
ARGS=()
for it in $(sketchybar --query date 2>/dev/null | jq -r '.popup.items[]?'); do
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
  if [ "$kind" = head ]; then
    # Centred by SketchyBar, not by padding the string: a padded label would be
    # clipped by exactly its leading blanks. GRID_W is the grid's own width,
    # 26 characters of JetBrainsMono at 12pt, so the header centres over it.
    ARGS+=(--add item "date.row$i" popup.date
           --set "date.row$i" icon.drawing=off
                 label="$LARROW $text $RARROW" label.color="$col"
                 label.font="$MONO" label.align=center label.width=$GRID_W
                 label.padding_left=12 label.padding_right=12
                 click_script="$SELF $((OFF + 1))"
                 script="$PLUGINS/calendar_scroll.sh $OFF"
           --subscribe "date.row$i" mouse.scrolled)
  else
    ARGS+=(--add item "date.row$i" popup.date
           --set "date.row$i" icon.drawing=off label="$text" label.color="$col"
                 label.font="$MONO" label.padding_left=12 label.padding_right=12)
  fi
done < <(python3 "$PLUGINS/calendar_grid.py" "$OFF")

nav() { # name icon label offset
  ARGS+=(--add item "date.$1" popup.date
         --set "date.$1" icon="$2" icon.color=$ACCENT label="$3" label.color=$LABEL
               label.font="$MONO"
               icon.padding_left=12 icon.padding_right=8 label.padding_right=14
               click_script="$SELF $4")
}

[ "$OFF" -ne 0 ] && nav today "󰃶" "Back to today" "0"

ARGS+=(--add item date.open popup.date
       --set date.open icon="󰃭" icon.color=$BLUE
             label="Open Calendar" label.color=$LABEL
             label.font="$MONO"
             icon.padding_left=12 icon.padding_right=8 label.padding_right=14
             click_script="$PLUGINS/open_calendar.sh")

if [ "$SHOW" -eq 0 ] && [ "$OFF" -eq 0 ] && [ $# -eq 0 ]; then
  ARGS+=(--set date popup.drawing=toggle --set battery popup.drawing=off --set volume popup.drawing=off)
else
  ARGS+=(--set date popup.drawing=on --set battery popup.drawing=off --set volume popup.drawing=off)
fi

sketchybar "${ARGS[@]}"
[ "$(sketchybar --query date | jq -r .popup.drawing)" = on ] && "$HOME/.config/sketchybar/plugins/popup_watch.sh" date >/dev/null 2>&1 &

