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
    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3tertiaryFixed : "#ffffff"
    clip: true

    Rectangle {
        id: backgroundRect
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: 22
        color: Config.useDynamicColors ? DynamicColors.tPalette.m3surfaceContainer : "#40000000"
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
                color: root.textColor
            }

            Resource {
                percentage: ResourceUsage.memoryUsedPercentage
                warningThreshold: 95
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "memory"
                color: root.textColor
            }

            Resource {
                percentage: ResourceUsage.cpuUsage
                warningThreshold: 80
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "gamepad"
                color: root.textColor
            }

            Resource {
                percentage: ResourceUsage.gpuUsage
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "developer_board"
                color: root.textColor
            }

            Resource {
                percentage: ResourceUsage.gpuMemUsage
            }
        }
    }
}
