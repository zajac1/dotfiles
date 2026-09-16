# Process counts per hot path, pinned exactly.
#
# Exact, not a ceiling: a number going down is also a change worth seeing. When
# one of these fails, decide whether the change was worth it and update the
# number in the same commit. That turns every fork added to a hot path into a
# line in the diff.
#
# Counted by PID arithmetic, which is load-independent. macOS allocates PIDs
# sequentially, so other activity can only inflate the gap, never shrink it,
# and the minimum over 8 runs is the true count. Milliseconds are reported but
# never asserted, because they move with load by more than any regression would.

pin() {  # pin <expected> <name> <cmd...>
  local want="$1" name="$2"; shift 2
  checkeq "$name" "$want" "$(procs 8 "$@")"
}

pin  6 "search keystroke        omni-query sl"        omni-query sl
pin  7 "search render           omni-query ''"        omni-query ""
pin 25 "root keystroke          omni-menu-query '' sl" omni-menu-query "" sl
pin 10 "root render             omni-menu-query ''"   omni-menu-query ""
pin 14 "style level             omni-menu-query style" omni-menu-query style
pin 14 "look level              omni-menu-query look" omni-menu-query look
pin  3 "omni-look current"                            omni-look current
pin  5 "omni-skip on a sep row"                       omni-skip "$(printf 'sep\t  x\t')" down

# Wall time, reported against the floor every path pays. Advisory only.
floor() { local S E i; S=$(/bin/date +%s.%N); for i in $(/usr/bin/seq 20); do /bin/bash -c true; done; E=$(/bin/date +%s.%N); /usr/bin/awk -v s="$S" -v e="$E" 'BEGIN{print (e-s)/20}'; }
ratio() {
  local name="$1"; shift
  local S E t f
  S=$(/bin/date +%s.%N); for i in $(/usr/bin/seq 20); do "$@" >/dev/null 2>&1; done; E=$(/bin/date +%s.%N)
  t=$(/usr/bin/awk -v s="$S" -v e="$E" 'BEGIN{print (e-s)/20}')
  f="$FLOOR"
  /usr/bin/awk -v t="$t" -v f="$f" -v n="$name" 'BEGIN{printf "  ---  %-34s %5.1f ms, %4.1fx floor\n", n, t*1000, t/f}'
}
FLOOR=$(floor)
ratio "omni-query sl"          omni-query sl
ratio "omni-menu-query '' sl"  omni-menu-query "" sl
ratio "omni-menu-query style"  omni-menu-query style
