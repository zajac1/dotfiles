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
checkeq "shader rewrites its key"      'OMNI_SHADER="dither.glsl"' "$(/usr/bin/grep -m1 '^OMNI_SHADER=' "$C")"

# omni-skip moves the cursor past rows that cannot be selected.
checkeq "skip past a sep row"   "down+transform(omni-skip {} down 2)" "$(omni-skip "$(row sep x '')" down)"
checkeq "a normal row is not skipped" "ignore" "$(omni-skip "$(row menu Style style)" down)"
checkeq "skip gives up at depth 40"   "ignore" "$(omni-skip "$(row sep x '')" down 40)"
