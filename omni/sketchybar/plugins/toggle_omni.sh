#!/bin/bash
# The launcher is bound to a global hotkey; there is no CLI to toggle a Ghostty
# quick terminal, so a click has to synthesise the keystroke. Needs Accessibility.
osascript -e 'tell application "System Events" to key code 49 using option down' 2>/dev/null
