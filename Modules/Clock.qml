import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Modules
import qs.Helpers as Helpers
import qs.Components

Item {
	id: root

	required property RowLayout loader
	required property Wrapper popouts
	required property PersistentProperties visibilities

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: timeText.contentWidth + 5 * 2

	CustomRect {
		anchors.bottomMargin: 3
		anchors.fill: parent
		anchors.topMargin: 3
		color: "transparent"
		radius: 4

		CustomText {
			id: timeText

			anchors.centerIn: parent
			color: DynamicColors.palette.m3onSurface
			text: Time.dateStr

			Behavior on color {
				CAnim {
				}
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
