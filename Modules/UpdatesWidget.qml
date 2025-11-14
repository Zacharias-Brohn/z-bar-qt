import QtQuick
import QtQuick.Layouts
import qs.Modules

Item {
    id: root
    required property int countUpdates
    implicitWidth: contentRow.childrenRect.width + 10
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#40000000"
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
            color: "#ffffff"
        }

        TextMetrics {
            id: textMetrics
            font.pixelSize: 16
            text: root.countUpdates
        }

        Text {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            text: textMetrics.text
            color: "white"
        }
    }
}
