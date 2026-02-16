pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Modules
import qs.Modules.Bar
import qs.Config
import qs.Helpers
import qs.Drawers

Variants {
	model: Quickshell.screens
	Scope {
		id: scope
		required property var modelData
        PanelWindow {
            id: bar
            property bool trayMenuVisible: false
            screen: scope.modelData
            color: "transparent"
            property var root: Quickshell.shellDir

			WlrLayershell.namespace: "ZShell-Bar"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            PanelWindow {
                id: exclusionZone
				WlrLayershell.namespace: "ZShell-Bar-Exclusion"
                screen: bar.screen
                WlrLayershell.layer: WlrLayer.Bottom
				WlrLayershell.exclusionMode: Config.autoHide ? ExclusionMode.Ignore : ExclusionMode.Auto
                anchors {
                    left: true
                    right: true
                    top: true
                }
                color: "transparent"
                implicitHeight: 34
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            mask: Region {
				id: region
                x: 0
                y: Config.autoHide && !visibilities.bar ? 4 : 34

				property list<Region> nullRegions: []
				property bool hcurrent: ( panels.popouts.hasCurrent && panels.popouts.currentName.startsWith("traymenu") ) || visibilities.sidebar || visibilities.dashboard

                width: hcurrent ? 0 : bar.width
                height: hcurrent ? 0 : bar.screen.height - backgroundRect.implicitHeight
                intersection: Intersection.Xor

                regions: hcurrent ? nullRegions : popoutRegions.instances
            }

            Variants {
                id: popoutRegions
                model: panels.children

                Region {
                    required property Item modelData

                    x: modelData.x
                    y: modelData.y + backgroundRect.implicitHeight
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Subtract
                }
            }

			CustomShortcut {
				name: "toggle-nc"

				onPressed: {
					visibilities.sidebar = !visibilities.sidebar
				}
			}

			PersistentProperties {
				id: visibilities

				property bool sidebar
				property bool dashboard
				property bool bar
				property bool osd

				Component.onCompleted: Visibilities.load(scope.modelData, this)
			}

            Item {
                anchors.fill: parent
                opacity: Config.transparency.enabled ? DynamicColors.transparency.base : 1
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    blurMax: 32
                    shadowColor: Qt.alpha(DynamicColors.palette.m3shadow, 1)
                }

                Border {
                    bar: backgroundRect
					visibilities: visibilities
                }

                Backgrounds {
					visibilities: visibilities
                    panels: panels
                    bar: backgroundRect
                }
            }

            Interactions {
				id: mouseArea
				screen: scope.modelData
				popouts: panels.popouts
				visibilities: visibilities
				panels: panels
				bar: barLoader
                anchors.fill: parent

                Panels {
                    id: panels
                    screen: scope.modelData
                    bar: backgroundRect
					visibilities: visibilities
                }

                Rectangle {
                    id: backgroundRect
                    property Wrapper popouts: panels.popouts
					anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: 34
					anchors.topMargin: Config.autoHide && !visibilities.bar ? -30 : 0
                    color: "transparent"
                    radius: 0


                    Behavior on color {
                        CAnim {}
                    }

					Behavior on anchors.topMargin {
						Anim {}
					}

                    BarLoader {
                        id: barLoader
                        anchors.fill: parent
                        popouts: panels.popouts
                        bar: bar
						visibilities: visibilities
						screen: scope.modelData
                    }
                }
            }
        }
    }
}
