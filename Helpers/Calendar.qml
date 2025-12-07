pragma Singleton

import Quickshell
import qs.Helpers

Singleton {
	id: root

	property int displayMonth: new Date().getMonth()
	property int displayYear: new Date().getFullYear()
	readonly property int weekStartDay: 1 // 0 = Sunday, 1 = Monday

	function getWeeksForMonth(month: int, year: int): var {
		const firstDayOfMonth = new Date(year, month, 1);
		const lastDayOfMonth = new Date(year, month + 1, 0);

		const days = [];
		let currentDate = new Date(year, month, 1);

		// Back up to the start of the first week (Sunday or Monday based on locale)
		const dayOfWeek = firstDayOfMonth.getDay();
		const daysToBackup = (dayOfWeek - root.weekStartDay + 7) % 7;
		currentDate.setDate(currentDate.getDate() - daysToBackup);

		// Collect all days, including padding from previous/next month to complete the weeks
		while (true) {
			days.push({
				day: currentDate.getDate(),
				month: currentDate.getMonth(),
				year: currentDate.getFullYear(),
				isCurrentMonth: currentDate.getMonth() === month,
				isToday: isDateToday(currentDate)
			});

			currentDate.setDate(currentDate.getDate() + 1);

			// Stop after we've completed a full week following the last day of the month
			if (currentDate > lastDayOfMonth && days.length % 7 === 0) {
				break;
			}
		}

		return days;
	}

	function getWeekNumbers(month: int, year: int): var {
		const days = getWeeksForMonth(month, year);
		const weekNumbers = [];
		let lastWeekNumber = -1;

		for (let i = 0; i < days.length; i++) {
			// Only add week numbers for days that belong to the current month
			if (days[i].isCurrentMonth) {
				const dayDate = new Date(days[i].year, days[i].month, days[i].day);
				const weekNumber = getISOWeekNumber(dayDate);

				// Only push if this is a new week
				if (weekNumber !== lastWeekNumber) {
					weekNumbers.push(weekNumber);
					lastWeekNumber = weekNumber;
				}
			}
		}

		return weekNumbers;
	}

	function getISOWeekNumber(date: var): int {
		const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
		const dayNum = d.getUTCDay() || 7;
		d.setUTCDate(d.getUTCDate() + 4 - dayNum);
		const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
		return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
	}

	function isDateToday(date: var): bool {
		const today = new Date();
		return date.getDate() === today.getDate() &&
			   date.getMonth() === today.getMonth() &&
			   date.getFullYear() === today.getFullYear();
	}

	function getWeekStartIndex(month: int, year: int): int {
		const today = new Date();
		if (today.getMonth() !== month || today.getFullYear() !== year) {
			return 0;
		}

		const days = getWeeksForMonth(month, year);
		for (let i = 0; i < days.length; i++) {
			if (days[i].isToday) {
				// Return the start index of the week containing today
				return Math.floor(i / 7) * 7;
			}
		}

		return 0;
	}
}
