import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Helpers
import qs.Config

CustomRect {
	id: root

	property int countUpdates: Updates.availableUpdates
	property color textColor: DynamicColors.palette.m3onSurface

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: contentRow.implicitWidth + Appearance.spacing.smaller
	radius: height / 2

	RowLayout {
		id: contentRow

		anchors.centerIn: parent
		spacing: Appearance.spacing.small

		MaterialIcon {
			font.pointSize: Appearance.font.size.larger
			text: "package_2"
		}

		CustomText {
			color: root.textColor
			font.pointSize: Appearance.font.size.normal
			text: root.countUpdates
		}
	}
}
