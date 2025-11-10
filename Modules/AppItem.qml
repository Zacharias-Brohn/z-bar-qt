import Quickshell
import Quickshell.Widgets
import QtQuick
import qs

Item {
    id: root

    required property DesktopEntry modelData

    implicitHeight: 48

    anchors.left: parent?.left
    anchors.right: parent?.right

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: event => onClicked(event)
        function onClicked(): void {
            Search.launch(root.modelData);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.margins: 4

        IconImage {
            id: icon

            source: Quickshell.iconPath( root.modelData?.icon, "image-missing" )
            implicitSize: parent.height * 0.8

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: 8
            anchors.verticalCenter: icon.verticalCenter

            implicitWidth: parent.width - icon.width
            implicitHeight: name.implicitHeight + comment.implicitHeight

            Text {
                id: name

                text: root.modelData?.name || qsTr("Unknown Application")
                font.pointSize: 12
                color: mouseArea.containsMouse ? "#ffffff" : "#cccccc"
                elide: Text.ElideRight
            }

            Text {
                id: comment

                text: ( root.modelData?.comment || root.modelData?.genericName || root.modelData?.name ) ?? ""
                font.pointSize: 10
                color: mouseArea.containsMouse ? "#dddddd" : "#888888"

                elide: Text.ElideRight
                width: root.width - icon.width - 4 * 2

                anchors.top: name.bottom
            }
        }
    }
}
