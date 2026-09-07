#!/usr/bin/env python3
"""Emit "kind<TAB>text" rows for the clock popup's month grid.

Takes an optional month offset (0 = this month, -1 = last, +1 = next).

Padding is NO-BREAK SPACE (U+00A0), not ASCII space, throughout. SketchyBar
trims runs of plain spaces when it measures a label, so rows that begin with
several of them - the header, and the first week of a month that does not start
on Monday - were measured short and drew clipped at the right. U+00A0 has the
same advance in a monospace font and survives the measurement.

Every day occupies a fixed FOUR character cell so the columns stay aligned
whether today is a one or two digit number. SketchyBar cannot colour part of a
label, so a bracket is the only way to point at a single day inside a row; the
bracket group is right-aligned so that " [7]" keeps the digit in the same
column as the plain cells instead of hanging a column to the left.
"""
import calendar
import datetime
import sys

NB = "\u00a0"
WIDTH = 7 * 4


def pad(text, width, how="center"):
    text = text.replace(" ", NB)
    short = width - len(text)
    if short <= 0:
        return text
    if how == "center":
        left = short // 2
        return NB * left + text + NB * (short - left)
    return text + NB * short


offset = int(sys.argv[1]) if len(sys.argv) > 1 else 0
today = datetime.date.today()
year, month = divmod(today.year * 12 + (today.month - 1) + offset, 12)
shown = datetime.date(year, month + 1, 1)

print("head\t" + pad(shown.strftime("%B %Y"), WIDTH))
print("dow\t" + "".join(pad(d, 4) for d in ("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su")))

for week in calendar.Calendar(firstweekday=0).monthdatescalendar(shown.year, shown.month):
    cells, has_today = [], False
    for day in week:
        if day.month != shown.month:
            cells.append(NB * 4)
        elif day == today:
            cells.append(pad(f"[{day.day}]".rjust(4), 4, "left"))
            has_today = True
        else:
            cells.append(pad(f"{day.day:2d}".rjust(3) + " ", 4, "left"))
    print(f"{'now' if has_today else 'week'}\t{''.join(cells)}")
