pragma Singleton

import Quickshell

Singleton {
	readonly property string amPmStr: timeComponents[2] ?? ""
	readonly property date date: clock.date
	property alias enabled: clock.enabled
	readonly property string hourStr: timeComponents[0] ?? ""
	readonly property int hours: clock.hours
	readonly property string minuteStr: timeComponents[1] ?? ""
	readonly property int minutes: clock.minutes
	readonly property int seconds: clock.seconds
	readonly property list<string> timeComponents: timeStr.split(":")
	readonly property string timeStr: format("hh:mm")

	function format(fmt: string): string {
		return Qt.formatDateTime(clock.date, fmt);
	}

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}
}
