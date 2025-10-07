import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root
    
    implicitWidth: workspacesRow.implicitWidth + 12
    implicitHeight: workspacesRow.implicitHeight + 8
    
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
        anchors.leftMargin: 6
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                required property var modelData

                width: 12
                height: 12
                radius: 6

                color: modelData.id === Hyprland.focusedWorkspace.id ? "#4080ff" : "#606060"

                border.color: modelData.id === Hyprland.focusedWorkspace.id ? "#60a0ff" : "#808080"
                border.width: 1

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
