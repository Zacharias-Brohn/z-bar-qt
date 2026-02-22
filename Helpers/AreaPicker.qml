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

        property bool freeze
        property bool closing

        Variants {
            model: Quickshell.screens
            PanelWindow {
                id: win
                color: "transparent"

                required property ShellScreen modelData

                screen: modelData
                WlrLayershell.namespace: "areapicker"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: root.closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
                mask: root.closing ? empty : null

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
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
		target: "picker"

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
