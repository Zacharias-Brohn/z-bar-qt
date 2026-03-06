import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property list<real> animCurve: MaterialEasing.emphasized
	property int animLength: MaterialEasing.emphasizedDecelTime
	readonly property Item current: content.item?.current ?? null
	property real currentCenter
	property string currentName
	property string detachedMode
	property bool hasCurrent
	readonly property bool isDetached: detachedMode.length > 0
	readonly property real nonAnimHeight: hasCurrent ? children.find(c => c.shouldBeActive)?.implicitHeight ?? content.implicitHeight : 0
	readonly property real nonAnimWidth: children.find(c => c.shouldBeActive)?.implicitWidth ?? content.implicitWidth
	property string queuedMode
	required property ShellScreen screen

	function close(): void {
		hasCurrent = false;
		animCurve = MaterialEasing.emphasizedDecel;
		animLength = MaterialEasing.emphasizedDecelTime;
		detachedMode = "";
		animCurve = MaterialEasing.emphasized;
	}

	function detach(mode: string): void {
		animLength = 600;
		if (mode === "winfo") {
			detachedMode = mode;
		} else {
			detachedMode = "any";
			queuedMode = mode;
		}
		focus = true;
	}

	clip: true
	implicitHeight: nonAnimHeight
	implicitWidth: nonAnimWidth
	visible: width > 0 && height > 0

	Behavior on implicitHeight {
		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}
	Behavior on implicitWidth {
		enabled: root.implicitHeight > 0

		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}

	// Comp {
	//     shouldBeActive: root.detachedMode === "winfo"
	//     asynchronous: true
	//     anchors.centerIn: parent
	//
	//     sourceComponent: WindowInfo {
	//         screen: root.screen
	//         client: Hypr.activeToplevel
	//     }
	// }

	// Comp {
	//     shouldBeActive: root.detachedMode === "any"
	//     asynchronous: true
	//     anchors.centerIn: parent
	//
	//     sourceComponent: ControlCenter {
	//         screen: root.screen
	//         active: root.queuedMode
	//
	//         function close(): void {
	//             root.close();
	//         }
	//     }
	// }

	Behavior on x {
		enabled: root.implicitHeight > 0

		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}
	Behavior on y {
		Anim {
			duration: root.animLength
			easing.bezierCurve: root.animCurve
		}
	}

	Keys.onEscapePressed: close()

	HyprlandFocusGrab {
		active: root.isDetached
		windows: [QsWindow.window]

		onCleared: root.close()
	}

	Binding {
		property: "WlrLayershell.keyboardFocus"
		target: QsWindow.window
		value: WlrKeyboardFocus.OnDemand
		when: root.isDetached
	}

	Comp {
		id: content

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		asynchronous: true
		shouldBeActive: root.hasCurrent

		sourceComponent: Content {
			wrapper: root
		}
	}

	component Comp: Loader {
		id: comp

		property bool shouldBeActive

		active: false
		asynchronous: true
		opacity: 0

		states: State {
			name: "active"
			when: comp.shouldBeActive

			PropertyChanges {
				comp.active: true
				comp.opacity: 1
			}
		}
		transitions: [
			Transition {
				from: ""
				to: "active"

				SequentialAnimation {
					PropertyAction {
						property: "active"
					}

					Anim {
						property: "opacity"
					}
				}
			},
			Transition {
				from: "active"
				to: ""

				SequentialAnimation {
					Anim {
						property: "opacity"
					}

					PropertyAction {
						property: "active"
					}
				}
			}
		]
	}
}
