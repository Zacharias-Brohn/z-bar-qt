import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Modules
import qs.Helpers as Helpers
import qs.Components

Item {
	id: root
	required property PersistentProperties visibilities
	required property Wrapper popouts
	required property RowLayout loader

    implicitWidth: timeText.contentWidth + 5 * 2
    anchors.top: parent.top
    anchors.bottom: parent.bottom

	CustomRect {
		anchors.fill: parent
		anchors.topMargin: 3
		anchors.bottomMargin: 3
		radius: 4
		color: "transparent"
		CustomText {
			id: timeText

			anchors.centerIn: parent

			text: Time.dateStr
			color: DynamicColors.palette.m3onSurface

			Behavior on color {
				CAnim {}
			}
		}

		StateLayer {
			acceptedButtons: Qt.LeftButton
			onClicked: {
				root.visibilities.dashboard = !root.visibilities.dashboard;
			}
		}
	}
}
