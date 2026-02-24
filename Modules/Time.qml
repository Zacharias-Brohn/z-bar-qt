pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	readonly property date date: clock.date
	readonly property string dateStr: format("ddd d MMM - hh:mm:ss")
	property alias enabled: clock.enabled
	readonly property string hourStr: timeComponents[0] ?? ""
	readonly property int hours: clock.hours
	readonly property string minuteStr: timeComponents[1] ?? ""
	readonly property int minutes: clock.minutes
	readonly property string secondStr: timeComponents[2] ?? ""
	readonly property int seconds: clock.seconds
	readonly property list<string> timeComponents: timeStr.split(":")
	readonly property string timeStr: format("hh:mm:ss")

	function format(fmt: string): string {
		return Qt.formatDateTime(clock.date, fmt);
	}

	SystemClock {
		id: clock

		precision: SystemClock.Seconds
	}
}
