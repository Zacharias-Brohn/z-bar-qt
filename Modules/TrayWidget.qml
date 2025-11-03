pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: root
    required property PanelWindow bar
    implicitHeight: parent.height
    implicitWidth: rowL.implicitWidth + 20
    color: "transparent"

    RowLayout {
        spacing: 10
        id: rowL
        anchors.centerIn: parent
        Repeater {
            id: repeater
            model: SystemTray.items
            TrayItem {
                id: trayItem
                required property SystemTrayItem modelData
                item: modelData
                bar: root.bar
            }
        }
    }
}
