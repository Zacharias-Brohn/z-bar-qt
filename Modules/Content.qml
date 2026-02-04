pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import qs.Config
import qs.Modules.Calendar
import qs.Modules.WSOverview
import qs.Modules.Polkit
import qs.Modules.Dashboard

Item {
    id: root

    required property Item wrapper
    readonly property Popout currentPopout: content.children.find(c => c.shouldBeActive) ?? null
    readonly property Item current: currentPopout?.item ?? null

    implicitWidth: (currentPopout?.implicitWidth ?? 0) + 5 * 2
    implicitHeight: (currentPopout?.implicitHeight ?? 0) + 5 * 2

    Item {
        id: content

        anchors.fill: parent

        Popout {
            name: "audio"
            sourceComponent: AudioPopup {
                wrapper: root.wrapper
            }
        }

        Popout {
            name: "resources"
            sourceComponent: ResourcePopout {
                wrapper: root.wrapper
            }
        }

        Repeater {
            model: ScriptModel {
                values: [ ...SystemTray.items.values ]
            }

            Popout {
                id: trayMenu

                required property SystemTrayItem modelData
                required property int index

                name: `traymenu${index}`
                sourceComponent: trayMenuComponent

                Connections {
                    target: root.wrapper

                    function onHasCurrentChanged(): void {
                        if ( root.wrapper.hasCurrent && trayMenu.shouldBeActive ) {
                            trayMenu.sourceComponent = null;
                            trayMenu.sourceComponent = trayMenuComponent;
                        }
                    }
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
				wrapper: root.wrapper
				screen: root.wrapper.screen
			}
		}

		Popout {
			name: "dash"

			sourceComponent: Dashboard {
				wrapper: root.wrapper
			}
		}
    }

    component Popout: Loader {
        id: popout

        required property string name
        readonly property bool shouldBeActive: root.wrapper.currentName === name

        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter

        opacity: 0
        scale: 0.8
        active: false

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
                        properties: "opacity,scale"
                        duration: MaterialEasing.expressiveEffectsTime
                    }
                    PropertyAction {
                        target: popout
                        property: "active"
                    }
                }
            },
            Transition {
                from: ""
                to: "active"

                SequentialAnimation {
                    PropertyAction {
                        target: popout
                        property: "active"
                    }
                    Anim {
                        properties: "opacity,scale"
                    }
                }
            }
        ]
    }
}
