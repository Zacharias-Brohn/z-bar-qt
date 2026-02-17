import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

Item {
    id: root

	required property PersistentProperties visibilities
	required property Wrapper popouts

    implicitWidth: 25
    anchors.top: parent.top
    anchors.bottom: parent.bottom

	CustomRect {
		anchors.fill: parent
		anchors.topMargin: 3
		anchors.bottomMargin: 3
		color: "transparent"
		radius: 4
		MaterialIcon {
			id: notificationCenterIcon

			anchors.centerIn: parent

			property color iconColor: DynamicColors.palette.m3tertiaryFixed

			text: HasNotifications.hasNotifications ? "\uf4fe" : "\ue7f4"
			font.family: "Material Symbols Rounded"
			font.pixelSize: 20
			color: iconColor

			Behavior on color {
				CAnim {}
			}
		}

		StateLayer {
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				root.visibilities.sidebar = !root.visibilities.sidebar;
				if ( root.visibilities.dashboard || root.popouts.hasCurrent ) {
					root.popouts.hasCurrent = false;
					root.visibilities.dashboard = false;
				}
			}
		}
	}
}
