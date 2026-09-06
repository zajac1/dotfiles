#!/bin/bash
# media_change gives us $INFO as JSON; no polling, no nowplaying-cli dependency
STATE=$(echo "$INFO" | jq -r ".state" 2>/dev/null)
TITLE=$(echo "$INFO" | jq -r ".title" 2>/dev/null)
ARTIST=$(echo "$INFO" | jq -r ".artist" 2>/dev/null)
if [ "$STATE" = "playing" ] && [ -n "$TITLE" ] && [ "$TITLE" != "null" ]; then
  sketchybar --set "$NAME" label="$ARTIST - $TITLE" drawing=on
else
  sketchybar --set "$NAME" label="Not Playing" drawing=on
fi
