import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Modules
import qs.Helpers as Helpers
import qs.Components

CustomRect {
	id: root

	required property RowLayout loader
	required property Wrapper popouts
	required property PersistentProperties visibilities

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: timeText.contentWidth + Appearance.padding.normal * 2
	radius: Appearance.rounding.full

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
