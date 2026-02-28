pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import qs.Config
import qs.Components
import qs.Modules.Calendar
import qs.Modules.WSOverview
import qs.Modules.Network
import qs.Modules.UPower

Item {
	id: root

	readonly property Item current: currentPopout?.item ?? null
	readonly property Popout currentPopout: content.children.find(c => c.shouldBeActive) ?? null
	required property Item wrapper

	implicitHeight: (currentPopout?.implicitHeight ?? 0) + 5 * 2
	implicitWidth: (currentPopout?.implicitWidth ?? 0) + 5 * 2

	Item {
		id: content

		anchors.fill: parent

		Popout {
			name: "audio"

			sourceComponent: AudioPopup {
				wrapper: root.wrapper
			}
		}

		Repeater {
			model: ScriptModel {
				values: [...SystemTray.items.values]
			}

			Popout {
				id: trayMenu

				required property int index
				required property SystemTrayItem modelData

				name: `traymenu${index}`
				sourceComponent: trayMenuComponent

				Connections {
					function onHasCurrentChanged(): void {
						if (root.wrapper.hasCurrent && trayMenu.shouldBeActive) {
							trayMenu.sourceComponent = null;
							trayMenu.sourceComponent = trayMenuComponent;
						}
					}

					target: root.wrapper
				}

				Component {
					id: trayMenuComponent

					TrayMenuPopout {
						popouts: root.wrapper
						trayItem: trayMenu.modelData.menu
					}
				}
			}
		}

		Popout {
			name: "calendar"

			sourceComponent: CalendarPopup {
				wrapper: root.wrapper
			}
		}

		Popout {
			name: "overview"

			sourceComponent: OverviewPopout {
				screen: root.wrapper.screen
				wrapper: root.wrapper
			}
		}

		Popout {
			name: "upower"

			sourceComponent: UPowerPopout {
				wrapper: root.wrapper
			}
		}

		Popout {
			name: "network"

			sourceComponent: NetworkPopout {
				wrapper: root.wrapper
			}
		}
	}

	component Popout: Loader {
		id: popout

		required property string name
		readonly property bool shouldBeActive: root.wrapper.currentName === name

		active: false
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 5
		opacity: 0
		scale: 0.8

		states: State {
			name: "active"
			when: popout.shouldBeActive

			PropertyChanges {
				popout.active: true
				popout.opacity: 1
				popout.scale: 1
			}
		}
		transitions: [
			Transition {
				from: "active"
				to: ""

				SequentialAnimation {
					Anim {
						duration: MaterialEasing.expressiveEffectsTime
						properties: "opacity,scale"
					}

					PropertyAction {
						property: "active"
						target: popout
					}
				}
			},
			Transition {
				from: ""
				to: "active"

				SequentialAnimation {
					PropertyAction {
						property: "active"
						target: popout
					}

					Anim {
						properties: "opacity,scale"
					}
				}
			}
		]
	}
}
