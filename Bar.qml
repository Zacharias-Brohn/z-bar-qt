pragma ComponentBehavior: Bound

import QtQuick
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
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            PanelWindow {
                id: exclusionZone
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

            NotificationCenter {
                bar: bar
            }

            Process {
                id: ncProcess
                command: ["sh", "-c", `qs -p ${bar.root}/shell.qml ipc call root showCenter`]
                running: false
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

                width: bar.width
                height: bar.screen.height - backgroundRect.implicitHeight
                intersection: Intersection.Xor

                regions: popoutRegions.instances
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

            Item {
                anchors.fill: parent
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
                    color: Config.useDynamicColors ? DynamicColors.tPalette.m3surface : Config.baseBgColor
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
