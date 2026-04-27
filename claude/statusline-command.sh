#!/bin/sh
input=$(cat)

cwd=$(echo "$input"      | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input"    | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_h_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_used=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')

dir=$(basename "$cwd")

git_branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    if [ -n "$dirty" ]; then git_branch="${branch}*"
    else git_branch="${branch}"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Catppuccin Mocha palette (true-color R;G;B)
# ---------------------------------------------------------------------------
CRUST="17;17;27"
BG_RED="243;139;168"      # dir
BG_PEACH="250;179;135"    # git branch
BG_YELLOW="249;226;175"   # model
BG_LAVENDER="180;190;254" # context window
BG_GREEN="166;227;161"    # rate ≥80%
BG_ORANGE="250;179;135"   # rate 40-79%  (peach — same as branch, different meaning)
BG_ALERT="243;139;168"    # rate <40%    (red — same as dir)

# Nerd Font glyphs via UTF-8 hex (avoids file-encoding issues)
SEP=$(printf '\xee\x82\xb0')          # U+E0B0  ► powerline right arrow
LEFT_CAP=$(printf '\xee\x82\xb6')    # U+E0B6   rounded left cap
RIGHT_CAP=$(printf '\xee\x82\xb4')   # U+E0B4   rounded right cap
ICON_BRANCH=$(printf '\xee\x82\xa0') # U+E0A0   git branch
ICON_CTX=$(printf '\xef\x83\xa4')    # U+F0E4   gauge/dashboard (context)
ICON_CLOCK=$(printf '\xef\x80\x97')  # U+F017   clock (5h)
ICON_CAL=$(printf '\xef\x81\xb3')    # U+F073   calendar (7d)

# ---------------------------------------------------------------------------
# Segment engine — connected powerline style, matching Starship
# ---------------------------------------------------------------------------
_prev_bg=""

seg() {
  _bg=$1; _content=$2
  if [ -n "$_prev_bg" ]; then
    printf '\033[38;2;%sm\033[48;2;%sm%s' "$_prev_bg" "$_bg" "$SEP"
  else
    printf '\033[0m\033[38;2;%sm%s\033[48;2;%sm' "$_bg" "$LEFT_CAP" "$_bg"
  fi
  printf '\033[38;2;%sm%s' "$CRUST" "$_content"
  _prev_bg=$_bg
}

endcap() {
  [ -n "$_prev_bg" ] && printf '\033[0m\033[38;2;%sm%s\033[0m' "$_prev_bg" "$RIGHT_CAP"
  printf '\n'
}

rate_bg() {
  if   [ "$1" -ge 80 ]; then rl_bg="$BG_GREEN"
  elif [ "$1" -ge 40 ]; then rl_bg="$BG_ORANGE"
  else                        rl_bg="$BG_ALERT"
  fi
}

# ---------------------------------------------------------------------------
# Build the statusline
# ---------------------------------------------------------------------------
seg "$BG_RED" " ${dir} "

[ -n "$git_branch" ] && seg "$BG_PEACH" " ${ICON_BRANCH} ${git_branch} "

[ -n "$model" ] && seg "$BG_YELLOW" " ${model} "

if [ -n "$used_pct" ]; then
  ctx_pct=$(printf "%.0f" "$used_pct")
  seg "$BG_LAVENDER" " ${ICON_CTX} ${ctx_pct}% "
fi

if [ -n "$five_h_used" ]; then
  five_h_rem=$(echo "$five_h_used" | awk '{printf "%.0f", 100 - $1}')
  rate_bg "$five_h_rem"
  seg "$rl_bg" " ${ICON_CLOCK} ${five_h_rem}% "
fi

if [ -n "$week_used" ]; then
  week_rem=$(echo "$week_used" | awk '{printf "%.0f", 100 - $1}')
  rate_bg "$week_rem"
  seg "$rl_bg" " ${ICON_CAL} ${week_rem}% "
fi

endcap
