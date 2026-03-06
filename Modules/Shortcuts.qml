import ZShell
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Helpers

Scope {
	id: root

	readonly property bool hasFullscreen: Hypr.focusedWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false
	property bool launcherInterrupted

	CustomShortcut {
		description: "Toggle launcher"
		name: "toggle-launcher"

		onPressed: root.launcherInterrupted = false
		onReleased: {
			if (!root.launcherInterrupted && !root.hasFullscreen) {
				const visibilities = Visibilities.getForActive();
				visibilities.launcher = !visibilities.launcher;
			}
			root.launcherInterrupted = false;
		}
	}

	CustomShortcut {
		name: "toggle-nc"

		onPressed: {
			const visibilities = Visibilities.getForActive();
			visibilities.sidebar = !visibilities.sidebar;
		}
	}

	CustomShortcut {
		name: "show-osd"

		onPressed: {
			const visibilities = Visibilities.getForActive();
			visibilities.osd = !visibilities.osd;
		}
	}

	CustomShortcut {
		name: "toggle-settings"

		onPressed: {
			const visibilities = Visibilities.getForActive();
			visibilities.settings = !visibilities.settings;
		}
	}
}
