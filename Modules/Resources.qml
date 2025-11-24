pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import qs.Modules
import qs.Config
import qs.Effects

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: 34
    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3tertiaryFixed : "#ffffff"

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: 22
        color: Config.useDynamicColors ? DynamicColors.tPalette.m3surfaceContainer : "#40000000"
        radius: height / 2
        RowLayout {
            id: rowLayout

            spacing: 6
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\uf7a3"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.memoryUsedPercentage
                warningThreshold: 95
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue322"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.cpuUsage
                warningThreshold: 80
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 16
                text: "\ue30f"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.gpuUsage
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue30d"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.gpuMemUsage
            }
        }
    }
}
