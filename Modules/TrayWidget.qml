pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: root

    anchors.top: parent.top
    anchors.bottom: parent.bottom

    required property PanelWindow bar
    readonly property alias items: repeater

    spacing: 0

    Repeater {
        id: repeater
        model: SystemTray.items
        TrayItem {
            id: trayItem
            required property SystemTrayItem modelData
            implicitHeight: 34
            implicitWidth: 28
            item: modelData
            bar: root.bar
        }
    }
}
