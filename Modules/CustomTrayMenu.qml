// CustomTrayMenu.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Window   // for Window, flags

PopupWindow {
    id: popup

    property QsMenuHandle menuHandle
    property alias entries: menuModel

    QsMenuOpener {
        id: menu
        menu: popup.menuHandle
    }

    ListModel { id: menuModel }

    implicitWidth: contentColumn.implicitWidth + 16
    implicitHeight: contentColumn.implicitHeight + 16

    Rectangle {
        color: "#202020CC"
        radius: 4
        anchors.fill: parent
    }

    Column {
        id: contentColumn
        anchors.fill: parent
        spacing: 4
        Repeater {
            id: repeater
            model: menuModel
            Row {
                id: entryRow
                height: 30
                width: parent.implicitWidth
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
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    function rebuild() {
        menuModel.clear()
        console.log(menu.children.count)
        if (!menu) return
        for (let i = 0; i < menu.children.count; ++i) {
            let e = menu.children.get(i)
            menuModel.append({
                text: e.text,
                icon: e.icon,
                triggered: e.triggered,
                entryObject: e
            })
        }
    }

    onMenuHandleChanged: rebuild
    Connections {
        target: menu
        function onCountChanged() {
            popup.rebuild
        }
    }
}
