import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

CustomRect {
	id: root

	required property Wrapper popouts
	required property PersistentProperties visibilities

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: implicitHeight
	radius: Appearance.rounding.full

	MaterialIcon {
		id: notificationCenterIcon

		property color iconColor: DynamicColors.palette.m3onSurface

		anchors.centerIn: parent
		color: iconColor
		font.family: "Material Symbols Rounded"
		font.pointSize: Appearance.font.size.larger
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
