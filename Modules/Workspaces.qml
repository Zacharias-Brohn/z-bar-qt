pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Config
import qs.Components

Item {
    id: itemRoot
    required property PanelWindow bar
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: workspacesRow.implicitWidth + 10
    Rectangle {
        id: root

        property HyprlandMonitor monitor: Hyprland.monitorFor( itemRoot.bar?.screen )

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
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
            anchors.leftMargin: 6
            spacing: 8

            Repeater {
                model: Hyprland.workspaces

                RowLayout {
                    id: workspaceIndicator
                    required property var modelData
                    visible: root.shouldShow( workspaceIndicator.modelData.monitor )
                    CustomText {
                        text: workspaceIndicator.modelData.name
                        font.pointSize: 12
                        color: workspaceIndicator.modelData.id === Hyprland.focusedWorkspace.id ? ( Config.useDynamicColors ? DynamicColors.palette.m3primary : Config.accentColor.accents.primary ) : ( Config.useDynamicColors ? DynamicColors.palette.m3onSurfaceVariant : "#606060" )
                        visible: true
                    }

                    Rectangle {

                        implicitWidth: 14
                        implicitHeight: 14
                        radius: height / 2
                        border.width: 1

                        color: "transparent"
                        border.color: workspaceIndicator.modelData.id === Hyprland.focusedWorkspace.id ? ( Config.useDynamicColors ? DynamicColors.palette.m3primary : Config.accentColor.accents.primary ) : ( Config.useDynamicColors ? DynamicColors.palette.m3onSurfaceVariant : "#606060" )


                        scale: 1.0
                        opacity: 1.0

                        CustomRect {
                            anchors.centerIn: parent
                            implicitWidth: 8
                            implicitHeight: 8

                            radius: implicitHeight / 2
                            color: workspaceIndicator.modelData.id === Hyprland.focusedWorkspace.id ? ( Config.useDynamicColors ? DynamicColors.palette.m3primary : Config.accentColor.accents.primary ) : "transparent"
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

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                workspaceIndicator.modelData.activate();
                            }
                        }
                    }
                }
            }
        }
    }
}
