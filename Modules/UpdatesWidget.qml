import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Config

Item {
    id: root
    property int countUpdates: Updates.availableUpdates
    implicitWidth: textMetrics.width + contentRow.spacing + 30
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    property color textColor: DynamicColors.palette.m3tertiaryFixed

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: 22
        radius: height / 2
        color: DynamicColors.tPalette.m3surfaceContainer
        Behavior on color {
            CAnim {}
        }
    }

    RowLayout {
        id: contentRow
        spacing: 10
        anchors {
            fill: parent
            leftMargin: 5
            rightMargin: 5
        }

        Text {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            text: "\uf569"
            color: root.textColor
            Behavior on color {
                CAnim {}
            }
        }

        TextMetrics {
            id: textMetrics
            font.pixelSize: 16
            text: root.countUpdates
        }

        Text {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            text: textMetrics.text
            color: root.textColor
            Behavior on color {
                CAnim {}
            }
        }
    }
}
