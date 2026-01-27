pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Modules
import qs.Modules.Bar
import qs.Config
import qs.Helpers
import qs.Drawers

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            property bool trayMenuVisible: false
            screen: modelData
            color: "transparent"
            property var root: Quickshell.shellDir

			WlrLayershell.namespace: "ZShell-Bar"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            PanelWindow {
                id: exclusionZone
				WlrLayershell.namespace: "ZShell-Bar-Exclusion"
                screen: bar.screen
                WlrLayershell.layer: WlrLayer.Bottom
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
                x: 0
                y: 34

				property list<Region> nullRegions: []
				property bool hcurrent: panels.popouts.hasCurrent && panels.popouts.currentName.startsWith("traymenu")

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
                    height: panels.popouts.hasCurrent ? modelData.height : 0
                    intersection: Intersection.Subtract
                }
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
                }

                Backgrounds {
                    panels: panels
                    bar: backgroundRect
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onContainsMouseChanged: {
                    if ( !containsMouse ) {
                        panels.popouts.hasCurrent = false;
                    }
                }

                onPositionChanged: event => {
                    if ( mouseY < backgroundRect.implicitHeight ) {
                        barLoader.checkPopout(mouseX);
                    }
                }

				onPressed: event => {
					var withinX = mouseX >= panels.popouts.x + 8 && mouseX < panels.popouts.x + panels.popouts.implicitWidth;
					var withinY = mouseY >= panels.popouts.y + exclusionZone.implicitHeight && mouseY < panels.popouts.y + exclusionZone.implicitHeight + panels.popouts.implicitHeight;


					if ( panels.popouts.hasCurrent ) {
						if ( withinX && withinY ) {
						} else {
							panels.popouts.hasCurrent = false;
						}
					}
				}

                Panels {
                    id: panels
                    screen: bar.modelData
                    bar: backgroundRect
                }

                Rectangle {
                    id: backgroundRect
                    property Wrapper popouts: panels.popouts
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    implicitHeight: 34
                    color: "transparent"
                    radius: 0

                    Behavior on color {
                        CAnim {}
                    }

                    BarLoader {
                        id: barLoader
                        anchors.fill: parent
                        popouts: panels.popouts
                        bar: bar
                    }

                    WindowTitle {
                        anchors.centerIn: parent
                        width: Math.min( 300, parent.width * 0.4 )
                        height: parent.height
                        z: 1
                    }
                }
            }
        }
    }
}
