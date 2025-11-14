pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Config

Rectangle {
    id: root

    required property PanelWindow bar
    property HyprlandMonitor monitor: Hyprland.monitorFor( root.bar?.screen )

    implicitWidth: workspacesRow.implicitWidth + 6
    implicitHeight: workspacesRow.implicitHeight + 7

    function shouldShow(monitor) {
        Hyprland.refreshWorkspaces();
        Hyprland.refreshMonitors();
        if ( monitor === root.monitor ) {
            return true;
        } else {
            return false;
        }
    }

    color: "#40000000"
    radius: height / 2

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
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
                required property var modelData

                width: 16
                height: 16
                radius: height / 2

                color: modelData.id === Hyprland.focusedWorkspace.id ? Config.accentColor.accents.primary : "#606060"

                border.color: modelData.id === Hyprland.focusedWorkspace.id ? Config.accentColor.accents.primaryAlt : "#808080"
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

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    font.pixelSize: 10
                    font.family: "Rubik"
                    color: modelData.id === Hyprland.focusedWorkspace.id ? Config.workspaceWidget.textColor : Config.workspaceWidget.inactiveTextColor
                }

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
