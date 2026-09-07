#!/bin/bash
# Close a popup once the pointer has actually left it - by geometry, not guess.
#
# SketchyBar's mouse.exited.global fires for a slow exit but can miss a fast
# one (upstream #564/#613/#638), stranding the popup. So while a popup is open
# one JXA loop polls the pointer and closes the popup when it is outside the
# union of the item's own rectangle and the popup's. Both come from the window
# server: every SketchyBar item and every popup row is its own window
# (CGWindowListCopyWindowInfo, matched by owner PID), so the region is exact.
# An OPEN popup's windows sit below the bar (y > 0) at layer 101 when SketchyBar
# opened it from a hover, or layer 0 when opened by a direct --show; the bar's
# items are the layer -20 windows at y = 0; unused popup windows park at
# x = -9999. Classify by position, not layer. The list must be requested with
# kCGWindowListOptionAll - OnScreenOnly omits the open popup entirely.
#
#   popup_watch.sh ITEM
set -u
ITEM="$1"
PID_FILE="$HOME/.cache/omni/popup.$ITEM.pid"
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then exit 0; fi
echo $$ > "$PID_FILE"
# TRAP: `pgrep -x sketchybar` returns NOTHING when run from a process sketchybar
# itself spawned - which is every real invocation of this script. Without a
# PID no window matched, the loop saw "no popup" and quit, and the popup was
# stranded; only watchers started from an interactive shell ever worked. Walk
# the parent chain instead; pgrep is the fallback for manual runs.
SB_PID=""; pp=$$
for _ in 1 2 3 4 5 6 7 8; do
  pp=$(/bin/ps -o ppid= -p "$pp" 2>/dev/null | tr -d ' '); [ -n "$pp" ] && [ "$pp" != 1 ] || break
  case "$(/bin/ps -o comm= -p "$pp" 2>/dev/null)" in */sketchybar|sketchybar) SB_PID=$pp; break ;; esac
done
[ -n "$SB_PID" ] || SB_PID=$(pgrep -x sketchybar | head -1)
[ -n "$SB_PID" ] || exit 0
VERDICT=$(osascript -l JavaScript - "$SB_PID" <<'JS' 2>/dev/null
ObjC.import("AppKit"); ObjC.import("CoreGraphics");
// Pure decision: returns "close" when the pointer has left the item+popup,
// "gone" when an event already closed it. Nothing here shells out - under
// sketchybar's environment that is exactly what could not be trusted.
function run(argv) {
  var pid = parseInt(argv[0], 10), SLACK = 6;
  var sh = $.NSScreen.mainScreen.frame.size.height;
  function rects() {
    var arr = ObjC.castRefToObject($.CGWindowListCopyWindowInfo($.kCGWindowListOptionAll, $.kCGNullWindowID));
    var bar = [], pop = null;
    for (var i = 0; i < arr.count; i++) {
      var d = arr.objectAtIndex(i);
      if (ObjC.unwrap(d.objectForKey("kCGWindowOwnerPID")) !== pid) continue;
      var b = ObjC.deepUnwrap(d.objectForKey("kCGWindowBounds"));
      var L = ObjC.unwrap(d.objectForKey("kCGWindowLayer"));
      if (b.X < -1000) continue;                               // parked = hidden
      var r = {x: b.X, y: b.Y, r: b.X + b.Width, b: b.Y + b.Height, w: b.Width};
      // TRAP: classify by POSITION, never by layer. A popup opened by SketchyBar's
      // own hover path sits at layer 101; one opened by a direct --show sits at
      // layer 0. The bar's own items are the layer -20 windows at y = 0.
      if (L >= 0 && b.Y > 0) {                                  // open popup rows
        pop = pop ? {x: Math.min(pop.x, r.x), y: Math.min(pop.y, r.y), r: Math.max(pop.r, r.r), b: Math.max(pop.b, r.b)} : r;
      } else bar.push(r);
    }
    if (!pop) return null;
    var it = null;   // the item: narrowest bar window whose right edge meets the popup's
    for (var j = 0; j < bar.length; j++) if (Math.abs(bar[j].r - pop.r) <= 8 && (!it || bar[j].w < it.w)) it = bar[j];
    return {pop: pop, item: it};
  }
  function inside(p, r) { return p.x >= r.x - SLACK && p.x <= r.r + SLACK && p.y >= r.y - SLACK && p.y <= r.b + SLACK; }
  var closedTicks = 0;
  for (var i = 0; i < 600; i++) {                               // 60s hard cap
    delay(0.1);
    var g = rects();
    if (!g) { if (++closedTicks > 15) return "gone"; continue; }
    closedTicks = 0;
    var m = $.NSEvent.mouseLocation, p = {x: m.x, y: sh - m.y};
    if (!inside(p, g.pop) && !(g.item && inside(p, g.item))) return "close";
  }
  return "close";
}
JS
)
[ "$VERDICT" = close ] && sketchybar --set "$ITEM" popup.drawing=off
/bin/rm -f "$PID_FILE"
