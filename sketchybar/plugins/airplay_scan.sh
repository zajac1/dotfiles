#!/bin/bash
# Discover AirPlay audio receivers (_raop._tcp over Bonjour) and cache their
# names. CoreAudio - and therefore SwitchAudioSource - does not know an AirPlay
# device exists until macOS has connected to it, which is why the volume popup
# used to list only the built-in speakers while the native menu showed the
# AirPort. Bonjour is where the native menu gets them from.
#
# dns-sd browses forever, so it is run for a fixed window in the background and
# the popup reads the cache; a hover must never block on the network.
set -u
CACHE="$HOME/.cache/omni/airplay.txt"
TMP="$CACHE.$$"
SELF=$(scutil --get ComputerName 2>/dev/null)
( dns-sd -B _raop._tcp local. > "$TMP.raw" 2>/dev/null & p=$!; sleep 2; kill "$p" 2>/dev/null )
# service names are "<mac>@<Name>"; Add lines only; drop this machine
awk '/ Add /{ n=$0; sub(/.*@/, "", n); print n }' "$TMP.raw" 2>/dev/null |
  sort -u | grep -vxF -- "$SELF" > "$TMP" || true
mv -f "$TMP" "$CACHE"; /bin/rm -f "$TMP.raw"
