pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Modules

Singleton {
	property int availableUpdates: 0

	Timer {
		interval: 1
		repeat: true
		running: true

		onTriggered: {
			updatesProc.running = true;
			interval = 5000;
		}
	}

	Process {
		id: updatesProc

		command: ["checkupdates"]
		running: false

		stdout: StdioCollector {
			onStreamFinished: {
				const output = this.text;
				const lines = output.trim().split("\n").filter(line => line.length > 0);
				availableUpdates = lines.length;
			}
		}
	}
}
