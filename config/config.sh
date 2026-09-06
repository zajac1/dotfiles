# omni configuration. Re-run `omni-start --restart` after changing anything
# that appears in the generated Ghostty config (font, colours, hotkey, frame).
#
# OMNI_CHROME is the number of rows fzf spends on borders/padding/input box.
# It is MEASURED on a real Ghostty quick terminal. A pty harness will tell you
# it is 7; it is 13. Setting it to 7 renders a 3-item menu. See bin/omni.
#
# OMNI_FILL_INSET controls how far the Favorites title band stops short of the
# right edge. Larger = safer. It exists because fzf and Ghostty disagree about
# usable width; see the --ellipsis note in bin/omni.
#
OMNI_THEME="matte-black"

OMNI_FONT="CaskaydiaMono Nerd Font Mono"
OMNI_FONT_SIZE=18

OMNI_MENU_COLS=38
OMNI_MENU_MAX_ROWS=24
OMNI_CHROME=13
OMNI_FILL_INSET=10

OMNI_COLS=60
OMNI_ROWS=24

OMNI_FRAME="boxed"
OMNI_OPACITY=0.95
OMNI_BLUR=20
OMNI_ANIMATION=0
OMNI_BORDER_STYLE="rounded"

OMNI_THEME_TERMINALS=false

OMNI_HOTKEY="alt+space"
OMNI_PROJECT_ROOT="$HOME/git"
OMNI_SEARCH_URL="https://duckduckgo.com/?q="

. "$HOME/.config/omni/themes/$OMNI_THEME.sh"
