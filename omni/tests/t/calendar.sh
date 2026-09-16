# emit_now in omni-menu-query: a meeting row lives from LEAD before the start
# until HOLD after it, or until the event ends, whichever comes first.
C="$HOME/.config/omni/config.sh"
TSV="$HOME/.cache/omni/calendar.tsv"
/usr/bin/sed -i '' 's/^OMNI_CALENDAR_VIEW=.*/OMNI_CALENDAR_VIEW="list"/' "$C"
/usr/bin/touch "$HOME/.cache/omni/calendar.status"   # fresh, so no refresh is spawned

# Offsets from the moment of the call, never from a NOW captured earlier: the
# boundaries are seconds apart and a whole suite run drifts past them.
ev() { local n; n=$(/bin/date +%s)
       printf '%s\t%s\t\t%s\t%s\n' "$((n + $1))" "$((n + $2))" "$3" "$4" > "$TSV"; }
titles() { omni-menu-query "" | /usr/bin/awk -F'\t' '$1=="url"||$1=="run"{print $2}'; }
count()  { omni-menu-query "" | /usr/bin/awk -F'\t' '($1=="url"||$1=="run") && $2 ~ /Meeting/ {n++} END{print n+0}'; }

# LEAD defaults to 300, HOLD to 1200
ev 295 3000 "09:00" "Meeting A"
checkeq "starts in LEAD-1 s, so it shows"        "1" "$(count)"

ev 305 3000 "09:00" "Meeting A"
checkeq "starts in LEAD+1 s, so it does not"     "0" "$(count)"

ev -1195 3000 "09:00" "Meeting A"
checkeq "started HOLD-1 s ago, so it shows"      "1" "$(count)"

ev -1205 3000 "09:00" "Meeting A"
checkeq "started HOLD+1 s ago, so it does not"   "0" "$(count)"

ev -600 -5 "09:00" "Meeting A"
checkeq "ended before HOLD, so it drops at its end" "0" "$(count)"

# three live events, capped at two rows
N=$(/bin/date +%s)
{ printf '%s\t%s\t\t09:00\tMeeting A\n' $((N - 60)) $((N + 3000))
  printf '%s\t%s\t\t09:30\tMeeting B\n' $((N - 50)) $((N + 3000))
  printf '%s\t%s\t\t10:00\tMeeting C\n' $((N - 40)) $((N + 3000)); } > "$TSV"
checkeq "three live events show two rows"        "2" "$(count)"

ev -60 3000 "09:00" "Meeting A"
checkeq "a query means no meeting row"           "0" "$(omni-menu-query '' meeting | /usr/bin/awk -F'\t' '$2 ~ /Meeting/ {n++} END{print n+0}')"

/usr/bin/sed -i '' 's/^OMNI_CALENDAR_VIEW=.*/OMNI_CALENDAR_VIEW="app"/' "$C"
checkeq "view=app means no meeting row"          "0" "$(count)"
