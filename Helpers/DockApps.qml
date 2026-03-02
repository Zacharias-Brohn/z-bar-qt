pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Config

Singleton {
	id: root

	property list<var> apps: {
		var map = new Map();

		const pinnedApps = Config.dock?.pinnedApps ?? [];
		for (const appId of pinnedApps) {
			if (!map.has(appId.toLowerCase()))
				map.set(appId.toLowerCase(), ({
						pinned: true,
						toplevels: []
					}));
		}

		if (pinnedApps.length > 0) {
			map.set("SEPARATOR", {
				pinned: false,
				toplevels: []
			});
		}

		var values = [];

		for (const [key, value] of map) {
			values.push(appEntryComp.createObject(null, {
				appId: key,
				toplevels: value.toplevels,
				pinned: value.pinned
			}));
		}

		return values;
	}

	function isPinned(appId) {
		return Config.dock.pinnedApps.indexOf(appId) !== -1;
	}

	function togglePin(appId) {
		if (root.isPinned(appId)) {
			Config.dock.pinnedApps = Config.dock.pinnedApps.filter(id => id !== appId);
		} else {
			Config.dock.pinnedApps = Config.dock.pinnedApps.concat([appId]);
		}
	}

	Component {
		id: appEntryComp

		TaskbarAppEntry {
		}
	}

	component TaskbarAppEntry: QtObject {
		id: wrapper

		required property string appId
		required property bool pinned
		required property list<var> toplevels
	}
}
