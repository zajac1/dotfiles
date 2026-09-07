#!/bin/bash
# Now Playing, from macOS's own MediaRemote via nowplaying-cli - so it works for
# TIDAL, Spotify, Music and browser audio alike. TIDAL ships no AppleScript
# dictionary, so asking the app directly is not an option.
#
# Driven by SketchyBar's media_change event; the update_freq is only a backstop
# for players that do not emit one. nowplaying-cli costs ~0.1s.
source "$HOME/.config/sketchybar/colors.sh"
for p in /opt/homebrew/bin /usr/local/bin; do [ -d "$p" ] && PATH="$p:$PATH"; done; export PATH

command -v nowplaying-cli >/dev/null 2>&1 || {
  sketchybar --set "$NAME" icon="󰎄" icon.color=$DIM label="No player"
  exit 0
}

TITLE=$(nowplaying-cli get title 2>/dev/null)
ARTIST=$(nowplaying-cli get artist 2>/dev/null)
RATE=$(nowplaying-cli get playbackRate 2>/dev/null)
case "$TITLE" in null|"") TITLE="" ;; esac
case "$ARTIST" in null|"") ARTIST="" ;; esac

# macOS keeps a "Now Playing" session for any browser tab that ever played
# media - paused, muted, or long forgotten - under the generic title "A site is
# playing media". That is not something playing. A paused REAL track (artist
# known, or a non-browser client) is still worth showing, as paused.
CLIENT=$(nowplaying-cli get-raw 2>/dev/null | sed -n 's/.*ClientBundleIdentifier[^a-zA-Z]*\([a-zA-Z0-9.-]*\).*/\1/p' | head -1)
case "$CLIENT" in *safari*|*chrome*|*firefox*|*zen*|*arc*|*browser*|*brave*|*edge*|*orion*|*vivaldi*) BROWSER=1 ;; *) BROWSER=0 ;; esac
case "$TITLE" in "A site is playing media"|"") GENERIC=1 ;; *) GENERIC=0 ;; esac
if [ "$GENERIC" = 1 ] || { [ "${RATE:-0}" = 0 ] && [ "$BROWSER" = 1 ] && [ -z "$ARTIST" ]; }; then
  sketchybar --set "$NAME" icon="󰎄" icon.color=$DIM label="Not Playing"
  exit 0
fi

# Truncated in python, not awk: macOS awk's length() counts BYTES, so any
# accented character in a track title would shorten the label unpredictably.
LABEL=$(TITLE="$TITLE" ARTIST="$ARTIST" python3 -c '
import os
t, a = os.environ["TITLE"], os.environ["ARTIST"]
s = f"{a} - {t}" if a else t
print(s if len(s) <= 32 else s[:31].rstrip() + "\u2026")')

if [ "${RATE:-0}" = "0" ]; then ICON="󰏤"; COL=$DIM
else ICON="󰐊"; COL=$MAGENTA; fi

sketchybar --set "$NAME" icon="$ICON" icon.color=$COL label="$LABEL"
