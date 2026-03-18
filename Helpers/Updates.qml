pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Paths

Singleton {
	id: root

	property int availableUpdates: 0
	property bool loaded
	property double now: Date.now()
	property var updates: ({})

	function formatUpdateTime(timestamp) {
		const diffMs = root.now - timestamp;
		const minuteMs = 60 * 1000;
		const hourMs = 60 * minuteMs;
		const dayMs = 24 * hourMs;

		if (diffMs < minuteMs)
			return "just now";

		if (diffMs < hourMs)
			return Math.floor(diffMs / minuteMs) + " min ago";

		if (diffMs < 48 * hourMs)
			return Math.floor(diffMs / hourMs) + " hr ago";

		return Qt.formatDateTime(new Date(timestamp), "dd hh:mm");
	}

	onUpdatesChanged: {
		if (!root.loaded)
			return;

		saveTimer.restart();
		availableUpdates = Object.keys(updates).length;
	}

	Timer {
		interval: 1
		repeat: true
		running: true

		onTriggered: {
			if (!root.loaded)
				return;

			updatesProc.running = true;
			interval = 5000;
		}
	}

	Timer {
		interval: 60000
		repeat: true
		running: true

		onTriggered: root.now = Date.now()
	}

	Process {
		id: updatesProc

		command: ["checkupdates"]
		running: false

		stdout: StdioCollector {
			onStreamFinished: {
				const output = this.text;
				const lines = output.trim().split("\n").filter(line => line.length > 0);

				const oldMap = root.updates;
				const now = Date.now();

				root.updates = lines.reduce((acc, pkg) => {
					acc[pkg] = oldMap[pkg] ?? now;
					return acc;
				}, {});
				root.availableUpdates = lines.length;
			}
		}
	}

	Timer {
		id: saveTimer

		interval: 1000

		onTriggered: storage.setText(JSON.stringify(root.updates))
	}

	FileView {
		id: storage

		path: `${Paths.state}/updates.json`

		onLoadFailed: err => {
			if (err === FileViewError.FileNotFound) {
				root.updates = ({});
				root.loaded = true;
				setText("{}");
				return;
			}

			root.updates = ({});
			root.loaded = true;
		}
		onLoaded: {
			try {
				const data = JSON.parse(text());
				root.updates = data && typeof data === "object" && !Array.isArray(data) ? data : {};
			} catch (e) {
				root.updates = ({});
			}

			root.loaded = true;
		}
	}
}
