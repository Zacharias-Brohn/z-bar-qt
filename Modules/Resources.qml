pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import qs.Modules
import qs.Config
import qs.Effects
import qs.Components

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: 34
    clip: true

    Rectangle {
        id: backgroundRect
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: 22
        color: DynamicColors.tPalette.m3surfaceContainer
        radius: height / 2
        Behavior on color {
            CAnim {}
        }
        RowLayout {
            id: rowLayout

            spacing: 6
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "memory_alt"
                color: DynamicColors.palette.m3primary
            }

            Resource {
                percentage: ResourceUsage.memoryUsedPercentage
                warningThreshold: 95
                mainColor: DynamicColors.palette.m3primary
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "memory"
                color: DynamicColors.palette.m3secondary
            }

            Resource {
                percentage: ResourceUsage.cpuUsage
                warningThreshold: 80
                mainColor: DynamicColors.palette.m3secondary
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "gamepad"
                color: DynamicColors.palette.m3tertiary
            }

            Resource {
                percentage: ResourceUsage.gpuUsage
                mainColor: DynamicColors.palette.m3tertiary
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "developer_board"
                color: DynamicColors.palette.m3primary
            }

            Resource {
                percentage: ResourceUsage.gpuMemUsage
                mainColor: DynamicColors.palette.m3primary
            }
        }
    }
}
