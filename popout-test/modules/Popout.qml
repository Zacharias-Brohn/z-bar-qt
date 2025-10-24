pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: root
    required property QsMenuHandle menu
    property int height: menuOpener.children.values.length * entryHeight
    property int entryHeight: 25
    implicitWidth: 300
    implicitHeight: height

    QsMenuOpener {
        id: menuOpener
        menu: root.menu
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Repeater {
            model: menuOpener.children
            Rectangle {
                id: menuItem
                width: root.implicitWidth
                height: modelData.isSeparator ? 5 : root.entryHeight
                color: mouseArea.containsMouse ? "#22000000" : "transparent"
                required property QsMenuEntry modelData
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        menuItem.modelData.triggered();
                        root.visible = false;
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: menuItem.modelData.text
                    }
                }
            }
        }
    }
}
