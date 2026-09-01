#!/bin/sh
# Rotates the background-gradient accent pair every ROTATE_DAYS days by
# rewriting the ACCENT_A/ACCENT_B lines in gradient-static-theme.glsl.
# Ghostty picks the change up on config reload (cmd+shift+,) or next start.
# Pairs are ANSI palette indices (theme-portable): see gradient-pairs preview.

SHADER="$HOME/.config/ghostty/shaders/gradient-static-theme.glsl"
ROTATE_DAYS=3
# winner | ocean | forest-B | ice | orchid | northern | dusk | pastel
PAIRS="4:5 6:4 2:12 12:15 5:13 6:5 1:5 15:13"

[ -f "$SHADER" ] || exit 0

set -- $PAIRS
IDX=$(( ($(date +%s) / 86400 / ROTATE_DAYS) % $# + 1 ))
eval "PAIR=\${$IDX}"
A=${PAIR%%:*}
B=${PAIR##*:}

grep -q "ACCENT_A = $A;" "$SHADER" && grep -q "ACCENT_B = $B;" "$SHADER" && exit 0

sed -i '' \
  -e "s/^const int ACCENT_A = [0-9]*;/const int ACCENT_A = $A;/" \
  -e "s/^const int ACCENT_B = [0-9]*;/const int ACCENT_B = $B;/" \
  "$SHADER"
