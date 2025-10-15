// CustomTrayMenu.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Window   // for Window, flags
import qs.Modules

PopupWindow {
    id: popup
    color: "#00202020"

    required property QsMenuOpener trayMenu

    Column {
        id: contentColumn
        anchors.fill: parent
        spacing: 4
        Repeater {
            id: repeater
            model: popup.trayMenu.children
            Row {
                id: entryRow
                anchors.fill: parent
                property var entry: modelData
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (entryRow.entry.triggered) {
                            entryRow.entry.triggered()
                        }
                        popup.visible = false
                    }
                }
                Image {
                    source: entryRow.entry.icon
                    width: 20; height: 20
                    visible: entryRow.entry.icon !== ""
                }
                Text {
                    text: entryRow.entry.text
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
