import ZShell
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Helpers

Scope {
	id: root

	property bool launcherInterrupted
	readonly property bool hasFullscreen: Hypr.focusedWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false


    CustomShortcut {
        name: "toggle-launcher"
        description: "Toggle launcher"
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
			const visibilities = Visibilities.getForActive()
			visibilities.sidebar = !visibilities.sidebar
		}
	}

	CustomShortcut {
		name: "show-osd"

		onPressed: {
			const visibilities = Visibilities.getForActive()
			visibilities.osd = !visibilities.osd
		}
	}
}
