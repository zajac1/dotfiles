#!/usr/bin/env python3
"""Emit "kind<TAB>text" rows for the clock popup's month grid.

Takes an optional month offset (0 = this month, -1 = last, +1 = next).

NO ROW MAY BEGIN WITH WHITESPACE. SketchyBar measures a label's drawing width
from the whitespace-trimmed string but then draws the untrimmed string clipped
to that width, so every leading blank costs one character off the RIGHT end.
That is what ate the year out of the header and the last day out of a first
week that did not start on Monday. Trailing blanks are harmless.

Hence: the header is left-aligned rather than centred, cells are left-aligned
so a day's digit sits at column 0 of its cell, and days spilling in from the
neighbouring month are drawn as a dot instead of being left blank.
"""
import calendar
import datetime
import sys

CELL = 4
OUT_OF_MONTH = "\u00b7"


def cell(text):
    return text.ljust(CELL)


offset = int(sys.argv[1]) if len(sys.argv) > 1 else 0
today = datetime.date.today()
year, month = divmod(today.year * 12 + (today.month - 1) + offset, 12)
shown = datetime.date(year, month + 1, 1)

# The header is NOT padded to centre it. Leading blanks get clipped (see
# above); SketchyBar's own label.align=center does the centring instead.
print("head\t" + shown.strftime("%B %Y"))
print("dow\t" + "".join(cell(d) for d in ("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su")))

for week in calendar.Calendar(firstweekday=0).monthdatescalendar(shown.year, shown.month):
    cells, has_today = [], False
    for day in week:
        if day.month != shown.month:
            cells.append(cell(OUT_OF_MONTH))
        elif day == today:
            cells.append(cell(f"[{day.day}]"))
            has_today = True
        else:
            cells.append(cell(str(day.day)))
    print(f"{'now' if has_today else 'week'}\t{''.join(cells).rstrip()}")
