OMNI_THEME="everforest"

OMNI_FONT="CaskaydiaMono Nerd Font Mono"
OMNI_FONT_SIZE=18

OMNI_MENU_COLS=38
OMNI_MENU_MAX_ROWS=34
OMNI_CHROME=13
OMNI_FILL_INSET=15

OMNI_COLS=60
OMNI_ROWS=24

# Blank lines between menu items. 0 = the old tight list.
OMNI_ROW_GAP=1
# Height of the (invisible) Ghostty window the box is centred in. Must exceed
# OMNI_MENU_MAX_ROWS or tall menus get clipped instead of centred.
OMNI_TERM_ROWS=36

OMNI_FRAME="boxed"
OMNI_OPACITY=0.95
OMNI_BLUR=20
OMNI_ANIMATION=0
OMNI_BORDER_STYLE="rounded"

OMNI_THEME_TERMINALS=false

OMNI_HOTKEY="alt+space"
OMNI_APP_COLORS=true

OMNI_PROJECT_ROOT="$HOME/git"
# We build this URL ourselves; macOS exposes no way to ask the default
# browser for its configured search engine.
OMNI_WEATHER_LOCATION=""   # empty = wttr.in IP geolocation
OMNI_WEATHER_TTL=900

OMNI_PASS_PROVIDER="protonpass"
OMNI_PASS_CACHE_TTL=900      # item TITLES only are cached, never secrets
OMNI_PASS_CLIPBOARD_TTL=30

OMNI_SEARCH_URL="https://www.google.com/search?q="

. "$HOME/.config/omni/themes/$OMNI_THEME.sh"
