import Quickshell
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

CustomRect {
	id: root

	required property PersistentProperties visibilities

	anchors.bottom: parent.bottom
	anchors.bottomMargin: 6
	anchors.top: parent.top
	anchors.topMargin: 6
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitWidth: 40
	radius: 1000

	StateLayer {
		onClicked: {
			root.visibilities.dashboard = !root.visibilities.dashboard;
		}
	}

	MaterialIcon {
		anchors.centerIn: parent
		color: DynamicColors.palette.m3onSurface
		text: "widgets"
	}
}
