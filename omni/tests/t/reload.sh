# omni-reload: regenerate the Ghostty config and tell the launcher to re-read it.
CONF="$HOME/.cache/omni/ghostty.conf"
MARK="$HOME/.cache/omni/preview"
C="$HOME/.config/omni/config.sh"

# With no launcher running it must refuse, and change nothing.
/bin/rm -f "$CONF" "$MARK"; : > "$HOME/calls.log"
omni-reload OMNI_FONT=Menlo >/dev/null 2>&1
checkeq "no launcher means exit 1"            "1" "$?"
checkeq "no launcher means no Apple event"    "0" "$(/usr/bin/grep -c '^osascript' "$HOME/calls.log")"
checkeq "no launcher leaves no marker"        "absent" "$([ -e "$MARK" ] && echo present || echo absent)"

# A process whose argv matches the pattern omni-reload greps for.
/bin/bash -c 'exec -a "ghostty --config-default-files=false --config-file='"$CONF"'" /bin/sleep 30' &
FAKE=$!
i=0
while ! /bin/ps -ax -o command= | /usr/bin/grep -q -- "[g]hostty .*--config-file=$CONF"; do
  i=$((i + 1)); [ "$i" -gt 50 ] && break; /bin/sleep 0.1
done

omni-start --conf-only >/dev/null 2>&1
font_before=$(/usr/bin/grep -m1 '^font-family' "$CONF")

: > "$HOME/calls.log"
omni-reload OMNI_FONT=Menlo >/dev/null 2>&1
checkeq "preview writes the override to the conf" "font-family = Menlo" "$(/usr/bin/grep -m1 '^font-family' "$CONF")"
checkeq "preview leaves a marker"                 "present" "$([ -e "$MARK" ] && echo present || echo absent)"
checkeq "preview fires one Apple event"           "1" "$(/usr/bin/grep -c '^osascript' "$HOME/calls.log")"
checkeq "preview does not touch config.sh"        "" "$(/usr/bin/grep '^OMNI_FONT=.*Menlo' "$C")"

: > "$HOME/calls.log"
omni-reload >/dev/null 2>&1
checkeq "revert restores the conf"    "$font_before" "$(/usr/bin/grep -m1 '^font-family' "$CONF")"
checkeq "revert removes the marker"   "absent" "$([ -e "$MARK" ] && echo present || echo absent)"

# Reloading with nothing changed must not bother the launcher.
: > "$HOME/calls.log"
omni-reload >/dev/null 2>&1
checkeq "an unchanged conf fires no event" "0" "$(/usr/bin/grep -c '^osascript' "$HOME/calls.log")"

# --conf-only takes only real keys, and only safe values. The key check alone
# is not enough: OMNI_THEME becomes part of a path that gets sourced.
omni-start --conf-only 'NOT_AN_OMNI_KEY=x; touch $HOME/pwned' >/dev/null 2>&1
checkeq "a key that is not OMNI_ is ignored" "absent" "$([ -e "$HOME/pwned" ] && echo present || echo absent)"

/bin/mkdir -p "$HOME/evil"
printf 'touch "$HOME/OWNED"\n' > "$HOME/evil/x.sh"
omni-start --conf-only 'OMNI_THEME=../../../evil/x' >/dev/null 2>&1
checkeq "a theme value cannot escape its directory" "absent" "$([ -e "$HOME/OWNED" ] && echo present || echo absent)"

omni-start --conf-only 'OMNI_THEME=everforest' >/dev/null 2>&1
checkeq "a real theme name still applies" "yes" "$(/usr/bin/grep -qc '^background = ' "$CONF" >/dev/null && echo yes || echo no)"

# With a launcher reachable, Font and Shader must reload rather than restart.
# This is the assertion menu-state.sh cannot make: without a launcher every
# path falls back to omni-restart, so both behaviours look identical there.
: > "$HOME/calls.log"
: > "$HOME/.cache/omni/stack"
out=$(omni-enter "$(printf 'font\t  Menlo\tMenlo')")
checkeq "font reloads instead of restarting" "0" "$(/usr/bin/grep -c '^launchctl' "$HOME/calls.log")"
checkeq "font returns to the menu"           "become(omni --menu)" "$out"

{ /bin/kill "$FAKE" 2>/dev/null; wait "$FAKE" 2>/dev/null; } 2>/dev/null
