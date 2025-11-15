import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Modules

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: 34

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: 22
        color: "#40000000"
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
                color: "#ffffff"
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
                color: "#ffffff"
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
                color: "#ffffff"
            }

            Resource {
                percentage: ResourceUsage.gpuUsage
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue30d"
                color: "#ffffff"
            }

            Resource {
                percentage: ResourceUsage.gpuMemUsage
            }
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Loader {
        anchors.left: parent.left
        sourceComponent: mouseArea.containsMouse ? resourcePopout : null
    }

    Component {
        id: resourcePopout
        PanelWindow {
            anchors {
                left: true
                top: true
                right: true
                bottom: true
            }
            color: "transparent"
            Rectangle {
                x: mapFromItem(root, 0, 0).x
                implicitHeight: 300
                implicitWidth: root.implicitWidth
                color: "#80000000"
                radius: 12
            }
        }
    }
}
