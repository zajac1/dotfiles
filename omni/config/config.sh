OMNI_THEME="everforest"

OMNI_FONT="CaskaydiaMono Nerd Font Mono"
OMNI_FONT_SIZE=18

OMNI_MENU_COLS=38
OMNI_MENU_MAX_ROWS=30
# Rows the fzf box spends on things that are not list items: borders, the
# input box, padding. It cannot be measured from outside the real terminal, so
# it is a calibration knob: too low and the last items are cut off, too high
# and there is dead space under the list.
OMNI_CHROME=10
OMNI_FILL_INSET=15

OMNI_COLS=60
OMNI_ROWS=24

# Blank lines between menu items. A whole blank line is a lot, so the real
# breathing room comes from OMNI_ROW_PAD below; leave this at 0.
OMNI_ROW_GAP=0
# Extra cell height for the launcher terminal, as a Ghostty adjust-cell-height
# value. This is the only way to get SUB-LINE row padding: a terminal cannot
# draw half a blank line. Applies to every row, borders included.
OMNI_ROW_PAD="30%"
# Height of the (invisible) Ghostty window the box is centred in. Must exceed
# OMNI_MENU_MAX_ROWS or tall menus get clipped instead of centred.
OMNI_TERM_ROWS=30
# Size of that window as Ghostty quick-terminal-size (width,height - percent of
# the screen or px). Must give at least OMNI_TERM_ROWS rows at the font size.
OMNI_TERM_SIZE="46%,96%"

OMNI_FRAME="boxed"
OMNI_OPACITY=0.95
OMNI_BLUR=20
OMNI_ANIMATION=0
OMNI_BORDER_STYLE="rounded"
# Input box border, separate from the outer box. "rounded" is a 3-row box;
# "bottom" is a 2-row underline, the only shorter option fzf offers.
OMNI_INPUT_BORDER="rounded"

OMNI_THEME_TERMINALS=false

OMNI_HOTKEY="alt+space"
OMNI_APP_COLORS=true

# How a theme's wallpaper is placed: fill | fit | center | stretch. A theme can
# override this in themes/<name>/wallpaper.toml, with a fill colour too.
# Let theme switches change the desktop picture at all (0 on a machine where
# the desktop is not yours to manage).
OMNI_WALLPAPER=1
OMNI_WALLPAPER_PLACEMENT="fill"
# Rotate through the active theme's backgrounds every N seconds (0 = never).
# Applied by `omni-wallpaper rotate on`, which omni-start runs.
OMNI_WALLPAPER_ROTATE=1800
# Crossfade wallpaper changes (an overlay of the outgoing picture fades out
# over the new one). Only when no agent restart is needed: one Space, or AeroSpace.
OMNI_WALLPAPER_FADE=1
OMNI_WALLPAPER_FADE_SECONDS=0.7

OMNI_PROJECT_ROOT="$HOME/git"
# We build this URL ourselves; macOS exposes no way to ask the default
# browser for its configured search engine.
OMNI_WEATHER_LOCATION=""   # empty = wttr.in IP geolocation
OMNI_WEATHER_TTL=900

# Utilities > Calendar and Mail dispatch to omni-calendar-<provider> and
# omni-mail-<provider>. omni ships "hey"; point these at your own executable
# on another machine (omni-mail-gmail, omni-calendar-gcal, ...) and nothing
# else has to change.
OMNI_CALENDAR_PROVIDER="hey"
OMNI_MAIL_PROVIDER="hey"

OMNI_PASS_PROVIDER="protonpass"
OMNI_PASS_CACHE_TTL=900      # item TITLES only are cached, never secrets
OMNI_PASS_CLIPBOARD_TTL=30

OMNI_SEARCH_URL="https://www.google.com/search?q="

# Colour roles are DERIVED from themes/$OMNI_THEME/colors.toml by
# omni-theme-build; the .sh is a cache and is rebuilt here if missing.
[ -f "$HOME/.cache/omni/themes/$OMNI_THEME.sh" ] || omni-theme-build "$OMNI_THEME" >/dev/null 2>&1
. "$HOME/.cache/omni/themes/$OMNI_THEME.sh"
