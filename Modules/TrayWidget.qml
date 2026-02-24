pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Row {
	id: root

	required property PanelWindow bar
	readonly property alias items: repeater
	required property RowLayout loader
	required property Wrapper popouts

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	spacing: 0

	Repeater {
		id: repeater

		model: SystemTray.items

		TrayItem {
			id: trayItem

			required property int index
			required property SystemTrayItem modelData

			bar: root.bar
			implicitHeight: 34
			implicitWidth: 34
			ind: index
			item: modelData
			loader: root.loader
			popouts: root.popouts
		}
	}
}
