pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Components
import qs.Config

Item {
	id: root

	readonly property alias items: repeater
	required property RowLayout loader
	required property Wrapper popouts

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitHeight: 34
	implicitWidth: row.width + Appearance.padding.small * 2

	CustomClippingRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: root.parent.height - ((Appearance.padding.small - 1) * 2)
		radius: height / 2

		Row {
			id: row

			anchors.centerIn: parent
			spacing: 0

			Repeater {
				id: repeater

				model: SystemTray.items

				TrayItem {
					id: trayItem

					required property int index
					required property SystemTrayItem modelData

					implicitHeight: 34
					implicitWidth: 34
					ind: index
					item: modelData
					loader: root.loader
					popouts: root.popouts
				}
			}
		}
	}
}
