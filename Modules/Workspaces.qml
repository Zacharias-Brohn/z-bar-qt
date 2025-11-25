pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Config

Item {
    id: itemRoot
    required property PanelWindow bar
    implicitHeight: 28
    implicitWidth: root.implicitWidth
    Rectangle {
        id: root

        property HyprlandMonitor monitor: Hyprland.monitorFor( itemRoot.bar?.screen )

        implicitWidth: workspacesRow.implicitWidth + 6
        implicitHeight: 22

        function shouldShow(monitor) {
            Hyprland.refreshWorkspaces();
            Hyprland.refreshMonitors();
            if ( monitor === root.monitor ) {
                return true;
            } else {
                return false;
            }
        }

        color: Config.useDynamicColors ? DynamicColors.tPalette.m3surfaceContainer : "#40000000"
        radius: height / 2

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            CAnim {}
        }

        RowLayout {
            id: workspacesRow
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 3
            spacing: 8

            Repeater {
                model: Hyprland.workspaces

                Rectangle {
                    id: workspaceIndicator
                    required property var modelData

                    width: 16
                    height: 16
                    radius: height / 2

                    color: modelData.id === Hyprland.focusedWorkspace.id ? ( Config.useDynamicColors ? DynamicColors.palette.m3primary : Config.accentColor.accents.primary ) : ( Config.useDynamicColors ? DynamicColors.palette.m3outline : "#606060" )

                    border.color: modelData.id === Hyprland.focusedWorkspace.id ? ( Config.useDynamicColors ? DynamicColors.palette.m3onPrimary : Config.accentColor.accents.primaryAlt ) : ( Config.useDynamicColors ? DynamicColors.palette.m3outlineVariant : "#808080" )
                    border.width: 1

                    visible: root.shouldShow( modelData.monitor )

                    scale: 1.0
                    opacity: 1.0

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    NumberAnimation on scale {
                        from: 0.0
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                    
                    NumberAnimation on opacity {
                        from: 0.0
                        to: 1.0
                        duration: 200
                    }

                    // Text {
                    //     anchors.centerIn: parent
                    //     text: modelData.id
                    //     font.pixelSize: 10
                    //     font.family: "Rubik"
                    //     color: modelData.id === Hyprland.focusedWorkspace.id ? Config.workspaceWidget.textColor : Config.workspaceWidget.inactiveTextColor
                    // }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Hyprland.dispatch("workspace " + modelData.id)
                        }
                    }
                }
            }
        }
    }
}
