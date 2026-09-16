# omni-look: a look is a complete set of values, and the active one is derived.
L="$HOME/.config/omni/looks"
C="$HOME/.config/omni/config.sh"
/bin/rm -f "$L"/*.sh


# written by hand so the order is explicit, since `current` returns the first match
/bin/cat > "$L/alpha.sh" <<EOF
OMNI_FONT_SIZE=18
OMNI_MENU_COLS=38
EOF
/bin/cat > "$L/beta.sh" <<EOF
OMNI_FONT_SIZE=21
OMNI_ROW_PAD="30%"
OMNI_TERM_SIZE="46%,96%"
EOF

/usr/bin/sed -i '' 's/^OMNI_FONT_SIZE=.*/OMNI_FONT_SIZE=18/; s/^OMNI_MENU_COLS=.*/OMNI_MENU_COLS=38/' "$C"
checkeq "current finds the look whose every key matches" "alpha" "$(omni-look current)"

/usr/bin/sed -i '' 's/^OMNI_MENU_COLS=.*/OMNI_MENU_COLS=40/' "$C"
checkeq "one differing key means no look is current" "" "$(omni-look current)"

/usr/bin/sed -i '' 's/^OMNI_FONT_SIZE=.*/OMNI_FONT_SIZE=21/; s/^OMNI_ROW_PAD=.*/OMNI_ROW_PAD="30%"/; s|^OMNI_TERM_SIZE=.*|OMNI_TERM_SIZE="46%,96%"|' "$C"
checkeq "a value holding % and , survives the comparison" "beta" "$(omni-look current)"

checkeq "list names every look file once" "alpha beta" "$(omni-look list | /usr/bin/tr '\n' ' ' | /usr/bin/sed 's/ $//')"

# apply rewrites only the keys the look names
printf 'OMNI_FONT_SIZE=18\nOMNI_MENU_COLS=38\n' > "$L/alpha.sh"
before_hotkey=$(/usr/bin/grep -m1 '^OMNI_HOTKEY=' "$C")
omni-look alpha >/dev/null 2>&1
checkeq "apply writes a key the look names"       "OMNI_FONT_SIZE=18" "$(/usr/bin/grep -m1 '^OMNI_FONT_SIZE=' "$C")"
checkeq "apply leaves a key the look omits alone" "$before_hotkey"    "$(/usr/bin/grep -m1 '^OMNI_HOTKEY=' "$C")"

# a look is parsed, never sourced
/bin/cat > "$L/evil.sh" <<EOF
OMNI_MENU_COLS=\$(touch "$HOME/pwned")
EOF
checkrc "a look with a substitution is refused" 1 omni-look evil
if [ -e "$HOME/pwned" ]; then
  checkeq "a look file cannot execute anything" "no pwned file" "pwned file created"
else
  checkeq "a look file cannot execute anything" "no pwned file" "no pwned file"
fi

# the restart signal, and that it goes through launchd exactly once
: > "$HOME/calls.log"
omni-look beta >/dev/null 2>&1
checkeq "applying a look calls launchctl once" "1" "$(/usr/bin/grep -c '^launchctl kickstart' "$HOME/calls.log")"
