# omni-enter, omni-back and omni-skip: the state machine behind every keypress.
S="$HOME/.cache/omni/stack"
C="$HOME/.config/omni/config.sh"
row() { printf '%s\t  %s\t%s' "$1" "$2" "$3"; }

: > "$S"
checkeq "a menu row pushes the stack" "become(omni --menu)" "$(omni-enter "$(row menu Style style)")"
checkeq "the stack now names that level" "style" "$(/usr/bin/tail -1 "$S")"

checkeq "back pops the stack" "become(omni --menu)" "$(omni-enter "$(row back Back '')")"
checkeq "the stack is empty again" "" "$(/usr/bin/tail -1 "$S")"

checkeq "a sep row is ignored" "ignore" "$(omni-enter "$(row sep 'A heading' '')")"
checkeq "an empty line is ignored" "ignore" "$(omni-enter '')"

# A Refresh row must hand fzf a reload-sync string, not run the fetch inline.
printf 'gitlab\n' > "$S"
got="$(omni-enter "$(row act Refresh gitlab-refresh)")"
case "$got" in
  "reload-sync(omni-exec >/dev/null 2>&1; omni-menu-query 'gitlab' {q})")
    checkeq "a refresh row defers to reload-sync" "ok" "ok" ;;
  *) checkeq "a refresh row defers to reload-sync" "reload-sync(...)" "$got" ;;
esac

# Font and shader rewrite exactly one line and do not restart when reload works.
: > "$S"
before=$(/usr/bin/wc -l < "$C" | /usr/bin/tr -d " ")
omni-enter "$(row font 'Menlo' 'Menlo')" >/dev/null 2>&1
checkeq "font rewrites its key"        'OMNI_FONT="Menlo"' "$(/usr/bin/grep -m1 '^OMNI_FONT=' "$C")"
checkeq "font changes no other line"   "$before" "$(/usr/bin/wc -l < "$C" | /usr/bin/tr -d ' ')"

omni-enter "$(row shader 'Dither' 'dither.glsl')" >/dev/null 2>&1

# config.sh is sourced everywhere, so a row payload must never reach it as code.
before_font=$(/usr/bin/grep -m1 '^OMNI_FONT=' "$C")
omni-enter "$(row font 'x' 'Menlo"; touch "$HOME/pwned"; echo "')" >/dev/null 2>&1
omni-query sl >/dev/null 2>&1
checkeq "a hostile font name never executes" "absent" "$([ -e "$HOME/pwned" ] && echo present || echo absent)"
checkeq "and it is not written at all"       "$before_font" "$(/usr/bin/grep -m1 '^OMNI_FONT=' "$C")"
omni-enter "$(row font 'x' 'Menlo')" >/dev/null 2>&1
checkeq "a normal font name still applies"   'OMNI_FONT="Menlo"' "$(/usr/bin/grep -m1 '^OMNI_FONT=' "$C")"
checkeq "shader rewrites its key"      'OMNI_SHADER="dither.glsl"' "$(/usr/bin/grep -m1 '^OMNI_SHADER=' "$C")"

# omni-skip moves the cursor past rows that cannot be selected.
checkeq "skip past a sep row"   "down+transform(omni-skip {} down 2)" "$(omni-skip "$(row sep x '')" down)"
checkeq "a normal row is not skipped" "ignore" "$(omni-skip "$(row menu Style style)" down)"
checkeq "skip gives up at depth 40"   "ignore" "$(omni-skip "$(row sep x '')" down 40)"

# omni-back is the Esc key, the most used key in the launcher, and nothing
# tested it. Replacing the whole script with `echo garbage` used to pass.
M="$HOME/.cache/omni/mode"
: > "$S"; printf 'menu\n' > "$M"
checkeq "esc with a query clears the query"   "clear-query"        "$(omni-back 'sl')"
checkeq "esc in search returns to the menu"   "become(omni --menu)" "$(printf 'search\n' > "$M"; omni-back '')"
printf 'menu\n' > "$M"; printf 'style\n' > "$S"
checkeq "esc in a level pops the stack"       "become(omni --menu)" "$(omni-back '')"
checkeq "the stack is empty after the pop"    ""                    "$(/usr/bin/tail -1 "$S")"
checkeq "esc at the root closes the launcher" "abort"               "$(omni-back '')"

# The look row through omni-enter: abort when omni-look had to restart,
# otherwise pop and re-render. Swapping the two used to pass.
printf 'look\n' > "$S"
cat > "$HOME/.local/bin/omni-look" <<'STUB'
#!/bin/bash
[ "$1" = current ] && exit 0
echo restart
STUB
chmod 755 "$HOME/.local/bin/omni-look"
checkeq "a look that restarts aborts the menu" "abort" "$(omni-enter "$(row look x np-tessera)")"
cat > "$HOME/.local/bin/omni-look" <<'STUB'
#!/bin/bash
[ "$1" = current ] && exit 0
exit 0
STUB
chmod 755 "$HOME/.local/bin/omni-look"
printf 'look\n' > "$S"
checkeq "a look that reloads returns to the menu" "become(omni --menu)" "$(omni-enter "$(row look x np-tessera)")"

# GOTCHAS 25: the cap has to clear the longest run of sep rows, which is 8.
checkeq "the skip cap is above the longest sep run" "ignore" "$(omni-skip "$(row sep x '')" down 40)"
checkeq "the cap has not dropped below 9"           "down+transform(omni-skip {} down 10)" "$(omni-skip "$(row sep x '')" down 9)"

