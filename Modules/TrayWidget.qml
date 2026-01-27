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
	required property Wrapper popouts
	required property RowLayout loader
    readonly property alias items: repeater

    spacing: 0

    Repeater {
        id: repeater
        model: SystemTray.items
        TrayItem {
            id: trayItem
            required property SystemTrayItem modelData
			required property int index
			ind: index
			popouts: root.popouts
			loader: root.loader
            implicitHeight: 34
            implicitWidth: 34
            item: modelData
            bar: root.bar
        }
    }
}
