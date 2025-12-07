#!/usr/bin/env python3
"""
Calendar cache generator for z-bar-qt
Generates a JSON file containing date numbers for all 52 weeks of 3 years (last, current, next)
Structure: { "2024": { "week_0": [1,2,3,4,5,6,7], ... }, "2025": {...}, ... }
"""

import json
import sys
from datetime import datetime, timedelta
from pathlib import Path


def get_week_start_day():
    """Returns the first day of the week (0=Sunday, 1=Monday, etc.) - hardcoded to Monday"""
    return 1  # Monday


def get_weeks_for_year(year, week_start_day=1):
    """
    Generate week data for a given year.
    Returns a dict with 52 weeks, each containing 7 date numbers.
    """
    weeks = {}

    # Find the first day of the year
    jan_1 = datetime(year, 1, 1)

    # Find the first week's start date (adjust based on week_start_day)
    first_date = jan_1 - timedelta(days=(jan_1.weekday() - week_start_day) % 7)

    # Generate 52 weeks
    for week_num in range(52):
        week_dates = []
        week_start = first_date + timedelta(weeks=week_num)

        for day_offset in range(7):
            current_date = week_start + timedelta(days=day_offset)
            week_dates.append(current_date.day)

        weeks[f"week_{week_num}"] = week_dates

    return weeks


def generate_calendar_cache(year=None):
    """Generate cache for last year, current year, and next year"""
    if year is None:
        year = datetime.now().year

    cache = {}
    for offset_year in [-1, 0, 1]:
        target_year = year + offset_year
        cache[str(target_year)] = get_weeks_for_year(target_year)

    return cache


def write_cache_file(cache_data):
    """Write cache to the same location as Paths.cache in QML"""
    import os

    # Use XDG_CACHE_HOME or ~/.cache, then add /zshell (matching Paths singleton)
    xdg_cache_home = os.environ.get("XDG_CACHE_HOME")
    if xdg_cache_home:
        cache_dir = Path(xdg_cache_home) / "zshell"
    else:
        cache_dir = Path.home() / ".cache" / "zshell"

    cache_dir.mkdir(parents=True, exist_ok=True)

    cache_file = cache_dir / "calendar_cache.json"

    with open(cache_file, "w") as f:
        json.dump(cache_data, f, indent=2)

    print(f"Calendar cache written to: {cache_file}")
    return cache_file


def main():
    try:
        # Generate cache for current year and ±1 year
        cache = generate_calendar_cache()

        # Write to file
        cache_file = write_cache_file(cache)

        print("Cache structure:")
        print("  - Keys: year (e.g., '2024', '2025', '2026')")
        print("  - Values: dict with 52 weeks")
        print("  - Each week: array of 7 date numbers")
        print(f"\nExample (first week of 2025):")
        print(f"  {cache['2025']['week_0']}")

        return 0
    except Exception as e:
        print(f"Error generating calendar cache: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
