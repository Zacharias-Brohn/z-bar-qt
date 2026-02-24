pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
	id: root

	property alias enabled: props.enabled
	readonly property alias enabledSince: props.enabledSince

	onEnabledChanged: {
		if (enabled)
			props.enabledSince = new Date();
	}

	PersistentProperties {
		id: props

		property bool enabled
		property date enabledSince

		reloadableId: "idleInhibitor"
	}

	IdleInhibitor {
		enabled: props.enabled

		window: PanelWindow {
			color: "transparent"
			implicitHeight: 0
			implicitWidth: 0

			mask: Region {
			}
		}
	}

	IpcHandler {
		function disable(): void {
			props.enabled = false;
		}

		function enable(): void {
			props.enabled = true;
		}

		function isEnabled(): bool {
			return props.enabled;
		}

		function toggle(): void {
			props.enabled = !props.enabled;
		}

		target: "idleInhibitor"
	}
}
