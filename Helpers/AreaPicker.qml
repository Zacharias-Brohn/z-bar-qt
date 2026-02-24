pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import ZShell
import qs.Components

Scope {
	LazyLoader {
		id: root

		property bool closing
		property bool freeze

		Variants {
			model: Quickshell.screens

			PanelWindow {
				id: win

				required property ShellScreen modelData

				WlrLayershell.exclusionMode: ExclusionMode.Ignore
				WlrLayershell.keyboardFocus: root.closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
				WlrLayershell.layer: WlrLayer.Overlay
				WlrLayershell.namespace: "areapicker"
				color: "transparent"
				mask: root.closing ? empty : null
				screen: modelData

				anchors {
					bottom: true
					left: true
					right: true
					top: true
				}

				Region {
					id: empty

				}

				Picker {
					loader: root
					screen: win.modelData
				}
			}
		}
	}

	IpcHandler {
		function open(): void {
			root.freeze = false;
			root.closing = false;
			root.activeAsync = true;
		}

		function openFreeze(): void {
			root.freeze = true;
			root.closing = false;
			root.activeAsync = true;
		}

		target: "picker"
	}

	CustomShortcut {
		name: "screenshot"

		onPressed: {
			root.freeze = false;
			root.closing = false;
			root.activeAsync = true;
		}
	}

	CustomShortcut {
		name: "screenshotFreeze"

		onPressed: {
			root.freeze = true;
			root.closing = false;
			root.activeAsync = true;
		}
	}
}
