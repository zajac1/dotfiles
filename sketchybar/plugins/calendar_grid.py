#!/usr/bin/env python3
"""Emit "kind<TAB>text" rows for the clock popup's month grid.

Every day occupies a fixed FOUR character cell so the columns stay aligned
whether today is a one or two digit number: "  7 " normally, "[ 7]" for today.
SketchyBar cannot colour part of a label, so that bracket is the only way to
point at a single day inside a row.
"""
import calendar
import datetime

WIDTH = 7 * 4
today = datetime.date.today()

print(f"head\t{today.strftime('%B %Y').center(WIDTH)}")
print("dow\t" + "".join(f"{d:^4}" for d in ("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su")))

for week in calendar.Calendar(firstweekday=0).monthdatescalendar(today.year, today.month):
    cells, has_today = [], False
    for day in week:
        if day.month != today.month:
            cells.append("    ")
        elif day == today:
            cells.append(f"[{day.day:2d}]")
            has_today = True
        else:
            cells.append(f" {day.day:2d} ")
    print(f"{'now' if has_today else 'week'}\t{''.join(cells)}")
