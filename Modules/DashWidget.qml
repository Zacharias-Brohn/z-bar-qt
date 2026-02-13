import Quickshell
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

CustomRect {
	id: root

	required property PersistentProperties visibilities

	anchors.top: parent.top
	anchors.bottom: parent.bottom
	anchors.topMargin: 6
	anchors.bottomMargin: 6
	implicitWidth: 40
	color: DynamicColors.tPalette.m3surfaceContainer
	radius: 1000

	StateLayer {
		onClicked: {
			root.visibilities.dashboard = !root.visibilities.dashboard;
		}
	}

	MaterialIcon {
		anchors.centerIn: parent
		text: "widgets"
		color: DynamicColors.palette.m3onSurface
	}
}
