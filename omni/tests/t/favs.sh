# mark_favs in omni-lib: a pin is a ranking tier, not a section.
. "$HOME/.local/bin/omni-lib"
S=$(printf ' \xef\x80\x85')   # the space and U+F005 that mark_favs appends

rows()        { printf 'app\t  Calendar\t/System/Applications/Calendar.app\n'
                printf 'app\t  Slack\t/Applications/Slack.app\n'
                printf 'app\t  Safari\t/Applications/Safari.app\n'; }
ranked()      { rows | mark_favs rank; }
marked()      { rows | mark_favs; }
capped()      { rows | mark_favs rank 2; }
sep_ranked()  { { printf 'sep\t  A heading\n'
                  printf 'app\t  Slack\t/Applications/Slack.app\n'; } | mark_favs rank; }

printf 'app\t/Applications/Slack.app\n' > "$HOME/.config/omni/favorites"

check "pinned row sorts first and carries the star" ranked <<EOF
app	  Slack$S	/Applications/Slack.app
app	  Calendar	/System/Applications/Calendar.app
app	  Safari	/Applications/Safari.app
EOF

check "without rank the star is added in place" marked <<EOF
app	  Calendar	/System/Applications/Calendar.app
app	  Slack$S	/Applications/Slack.app
app	  Safari	/Applications/Safari.app
EOF

check "the cap counts pinned and rest together" capped <<EOF
app	  Slack$S	/Applications/Slack.app
app	  Calendar	/System/Applications/Calendar.app
EOF

check "a two-field sep row passes through unstarred" sep_ranked <<EOF
app	  Slack$S	/Applications/Slack.app
sep	  A heading
EOF

printf '/Applications/Safari.app\n' > "$HOME/.config/omni/favorites"
check "a legacy bare path still pins an app" ranked <<EOF
app	  Safari$S	/Applications/Safari.app
app	  Calendar	/System/Applications/Calendar.app
app	  Slack	/Applications/Slack.app
EOF

: > "$HOME/.config/omni/favorites"
check "no favourites means no stars and no reorder" ranked <<EOF
app	  Calendar	/System/Applications/Calendar.app
app	  Slack	/Applications/Slack.app
app	  Safari	/Applications/Safari.app
EOF

/bin/rm -f "$HOME/.config/omni/favorites"
check "a missing favourites file is not an error" ranked <<EOF
app	  Calendar	/System/Applications/Calendar.app
app	  Slack	/Applications/Slack.app
app	  Safari	/Applications/Safari.app
EOF
