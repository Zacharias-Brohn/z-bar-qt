pragma Singleton

import Quickshell

Singleton {
	property var bars: new Map()
	property var screens: new Map()

	function getForActive(): PersistentProperties {
		return screens.get(Hypr.focusedMonitor);
	}

	function load(screen: ShellScreen, visibilities: var): void {
		screens.set(Hypr.monitorFor(screen), visibilities);
	}
}
