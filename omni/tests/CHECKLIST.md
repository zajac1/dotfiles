# By hand, after touching omni-start, omni-reload, omni-restart, omni-look, or the fzf argv in omni

These only exist with the real process tree. A harness that passes while the
real thing fails is what gotchas 1, 37 and 38 are about. About four minutes.

To use a throwaway launcher instead of the live one: copy `config.sh` to a
scratch HOME, change `OMNI_HOTKEY`, start it with `HOME=<scratch> omni-start`,
and kill it afterwards with
`pkill -f "config-file=<scratch>/.cache/omni/ghostty.conf"`. That pattern
cannot match the live launcher.

```
[ ] Hotkey opens. Second press closes it, and does not open a second window.
[ ] Root menu: the first row is highlighted, not a heading. Down from the last row wraps.
[ ] Type "sl" at root: Sleep appears. Type "yes": only the web row.
[ ] Ctrl+P on an app, then again: the star appears, then goes. ~/.config/omni/favorites changes both times.
[ ] Search two letters: a starred match sorts above the others.
[ ] Style > Theme: arrow through three, colours change as you move. Esc puts them back.
[ ] Style > Font: arrow to another family, glyphs change within about a second. Esc puts it back.
[ ] Style > Shader: arrow, the background changes. Enter keeps it, the menu returns, nothing restarts.
[ ] Style > Look: arrow, colours and font and shader all change together. Esc puts them back.
[ ] Enter a look with the same OMNI_TERM_SIZE: no restart. One with a different size: the launcher closes and comes back on its own within about three seconds.
[ ] After a look, Style > Look shows the tick on it. Change the shader, and the tick is gone.
[ ] Work > GitLab, press Refresh: the rows stay on screen and swap when it lands. Press again mid-flight: still no Loading row.
[ ] Passwords, press Refresh: the new list arrives without leaving the level.
[ ] A meeting starting within five minutes shows at the root. Twenty minutes after it starts, it is gone.
[ ] Last line of ~/.cache/omni/term.size: rows and cols match a screenshot count. This is the only dimension check that means anything.
[ ] Kill the launcher with pkill on its config path. The hotkey is dead. omni-restart from a shell brings it back.
```

Not checked at all: shader correctness beyond "it renders", quick-terminal-size
values, the wallpaper store, AeroSpace, SketchyBar.
