# Sourced by tests/run. Every test runs with HOME pointing at a throwaway
# directory, because every omni script resolves its state as $HOME/.config/omni
# and $HOME/.cache/omni with no override variable. That is the only lever and
# it is enough.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0
CHECKS=0
# Captured once: sandbox() points TMPDIR inside the sandbox, so the next
# file's mktemp would otherwise resolve into the directory just deleted.
BASE_TMP="${TMPDIR:-/tmp}"

sandbox() {
  SB="$(/usr/bin/mktemp -d "$BASE_TMP/omni-test.XXXXXX")"
  export HOME="$SB"
  export TMPDIR="$SB/tmp"
  /bin/mkdir -p "$SB/.local/bin" "$SB/.config/omni/looks" "$SB/.cache/omni" "$SB/tmp"
  /usr/bin/install -m 0755 "$SRC"/bin/omni* "$SB/.local/bin/"
  export PATH="$SB/.local/bin:/opt/homebrew/bin:/usr/bin:/bin"

  # Anything that reaches outside HOME is replaced by a logging no-op.
  for s in open osascript launchctl pkill sketchybar glab omni-ek \
           pbcopy pbpaste caffeinate omni-notify omni-wallpaper nvim; do
    printf '#!/bin/bash\nprintf "%%s %%s\\n" "%s" "$*" >> "$HOME/calls.log"\nexit 0\n' "$s" \
      > "$SB/.local/bin/$s"
    /bin/chmod 755 "$SB/.local/bin/$s"
  done
  : > "$SB/calls.log"

  /bin/cp "$SRC/config/config.sh" "$SB/.config/omni/config.sh"
  /bin/cp "$SRC/config/sections.example" "$SB/.config/omni/sections"
  : > "$SB/.config/omni/favorites"
  : > "$SB/.config/omni/glyphs"
  /bin/cp "$SRC"/config/looks/*.sh "$SB/.config/omni/looks/" 2>/dev/null || true
  /bin/mkdir -p "$SB/.config/omni/themes"
  /bin/cp -R "$SRC"/config/themes/* "$SB/.config/omni/themes/"
  # Compiling 25 themes costs 2 s, and it is identical for every file. Build it
  # once per run and copy it in.
  if [ -z "${THEME_CACHE:-}" ]; then
    THEME_CACHE="$BASE_TMP/omni-test-themes.$$"
    /bin/mkdir -p "$THEME_CACHE"
    HOME="$SB" "$SB/.local/bin/omni-theme-build" --all >/dev/null 2>&1
    /bin/cp "$SB/.cache/omni/themes/"*.sh "$THEME_CACHE/" 2>/dev/null
  else
    /bin/mkdir -p "$SB/.cache/omni/themes"
    /bin/cp "$THEME_CACHE/"*.sh "$SB/.cache/omni/themes/" 2>/dev/null
  fi

  # Seeded so omni-query never falls through to omni-index, which scans /Applications.
  printf 'app\t  Calendar\t/System/Applications/Calendar.app\n' >  "$SB/.cache/omni/index.tsv"
  printf 'app\t  Slack\t/Applications/Slack.app\n'             >> "$SB/.cache/omni/index.tsv"
  printf 'app\t  Safari\t/Applications/Safari.app\n'           >> "$SB/.cache/omni/index.tsv"
  printf 'app\t  Figma\t/Applications/Figma.app\n'             >> "$SB/.cache/omni/index.tsv"
  printf 'project\t  omni\t%s\n' "$SRC"                        >> "$SB/.cache/omni/index.tsv"
}

teardown() {
  [ -n "${SB:-}" ] && [ -d "$SB" ] && /bin/rm -rf "$SB"
}

# check <name> <expected-heredoc-on-stdin> -- runs "$@" after the name
check() {
  local name="$1"; shift
  local want got
  want="$(/bin/cat)"
  got="$("$@" 2>&1)"
  CHECKS=$((CHECKS + 1))
  if [ "$got" = "$want" ]; then
    printf '  ok   %s\n' "$name"
  else
    printf '  FAIL %s\n' "$name"
    /usr/bin/diff <(printf '%s\n' "$want") <(printf '%s\n' "$got") | /usr/bin/sed 's/^/       /'
    FAILED=$((FAILED + 1))
  fi
}

# checkeq <name> <expected> <actual>
checkeq() {
  CHECKS=$((CHECKS + 1))
  if [ "$2" = "$3" ]; then
    printf '  ok   %s\n' "$1"
  else
    printf '  FAIL %s  expected [%s] got [%s]\n' "$1" "$2" "$3"
    FAILED=$((FAILED + 1))
  fi
}

# checkrc <name> <expected-status> <cmd...>
# check() compares stdout only, so a script that prints the right thing and
# exits 1 passes it. Use this where the status is the contract.
checkrc() {
  local name="$1" want="$2"; shift 2
  "$@" >/dev/null 2>&1
  checkeq "$name" "$want" "$?"
}

# procs <runs> <cmd...>  -- minimum processes spawned, load-independent.
# macOS allocates PIDs sequentially, so other activity can only inflate the
# gap, never shrink it. The minimum over N runs is therefore the true count.
procs() {
  local n="$1"; shift
  local best=99999 a b d i
  for i in $(/usr/bin/seq 1 "$n"); do
    a=$(/bin/sh -c 'echo $$'); "$@" >/dev/null 2>&1; b=$(/bin/sh -c 'echo $$')
    d=$((b - a - 1))
    [ "$d" -ge 0 ] && [ "$d" -lt "$best" ] && best="$d"
  done
  printf '%s' "$best"
}
