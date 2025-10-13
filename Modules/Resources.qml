import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Modules

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin

    Rectangle {
        anchors.fill: parent
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
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue30d"
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
}
