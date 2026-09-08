#!/bin/bash
# Just the time. The date lives in its own item to the left, which is also
# where the calendar popup hangs.
#
# Seconds are deliberately left off: they would need update_freq=1, and every
# sketchybar call costs ~25ms - a fork per second forever for a digit nobody
# reads.
sketchybar --set "$NAME" label="$(date "+%H:%M")"
