pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd d MMM - hh:mm:ss")
    }

	readonly property string shortTime: {
		Qt.formatDateTime(clock.date, "hh:mm")
	}

	readonly property string longTime: {
		Qt.formatDateTime(clock.date, "hh:mm:ss")
	}

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
