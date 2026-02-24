import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

Item {
	id: root

	required property Wrapper popouts
	required property PersistentProperties visibilities

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: 25

	CustomRect {
		anchors.bottomMargin: 3
		anchors.fill: parent
		anchors.topMargin: 3
		color: "transparent"
		radius: 4

		MaterialIcon {
			id: notificationCenterIcon

			property color iconColor: DynamicColors.palette.m3onSurface

			anchors.centerIn: parent
			color: iconColor
			font.family: "Material Symbols Rounded"
			font.pixelSize: 20
			text: HasNotifications.hasNotifications ? "\uf4fe" : "\ue7f4"

			Behavior on color {
				CAnim {
				}
			}
		}

		StateLayer {
			cursorShape: Qt.PointingHandCursor

			onClicked: {
				root.visibilities.sidebar = !root.visibilities.sidebar;
			}
		}
	}
}
