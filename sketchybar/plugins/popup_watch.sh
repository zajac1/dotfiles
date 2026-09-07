#!/bin/bash
# Close a popup once the pointer has actually left it.
#
# SketchyBar's mouse.exited.global does fire for a slow, deliberate exit, but
# upstream #564/#613/#638 and this bar's own history say a fast one can miss
# it and leave the popup stranded. So while a popup is open, one small JXA
# loop polls the pointer (~every 150ms, one process, exits with the popup) and
# closes it the moment the pointer is outside the bar-plus-popup band. Events
# still close it first when they work; this is the floor, not the path.
#
#   popup_watch.sh ITEM ROWS      ROWS = popup rows, for the height estimate
set -u
ITEM="$1"; ROWS="${2:-6}"
PID="$HOME/.cache/omni/popup.$ITEM.pid"
if [ -f "$PID" ] && kill -0 "$(cat "$PID")" 2>/dev/null; then exit 0; fi
echo $$ > "$PID"
# bar 30 + rows*26 + popup chrome; generous, a stale popup is the worse fault
H=$(( 30 + ROWS * 26 + 24 ))
osascript -l JavaScript - "$ITEM" "$H" <<'JS' >/dev/null 2>&1
ObjC.import("AppKit");
function run(argv) {
  var item = argv[0], h = parseInt(argv[1], 10);
  var scr = $.NSScreen.mainScreen.frame, w = scr.size.width, sh = scr.size.height;
  var app = Application.currentApplication(); app.includeStandardAdditions = true;
  for (var i = 0; i < 400; i++) {                 // 60s hard cap
    delay(0.15);
    var q = app.doShellScript("sketchybar --query " + item + " 2>/dev/null | /usr/bin/grep -c '\"drawing\": \"on\"' ; true");
    if (q.indexOf("0") === 0) return;             // closed by an event already
    var p = $.NSEvent.mouseLocation, top = sh - p.y;
    if (top > h || p.x < w - 520) {
      app.doShellScript("sketchybar --set " + item + " popup.drawing=off"); return;
    }
  }
  app.doShellScript("sketchybar --set " + item + " popup.drawing=off");
}
JS
/bin/rm -f "$PID"
