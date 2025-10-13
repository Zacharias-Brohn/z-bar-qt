import QtQuick
import QtQuick.Layouts
import qs.Modules

Item {
    id: root
    required property int countUpdates
    implicitWidth: 60
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#40000000"
    }

    RowLayout {
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

        Item {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            implicitWidth: 18
            implicitHeight: root.implicitHeight


            Text {
                anchors.centerIn: parent
                text: root.countUpdates
                color: "white"
            }
        }
    }
}
