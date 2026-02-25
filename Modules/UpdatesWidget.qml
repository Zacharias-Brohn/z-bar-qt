import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Config

Item {
	id: root

	property int countUpdates: Updates.availableUpdates
	property color textColor: DynamicColors.palette.m3onSurface

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: contentRow.childrenRect.width + Appearance.spacing.smaller

	CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 22
		radius: height / 2
	}

	RowLayout {
		id: contentRow

		anchors.centerIn: parent
		implicitHeight: 22
		spacing: Appearance.spacing.small

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			font.pointSize: 14
			text: "package_2"
		}

		TextMetrics {
			id: textMetrics

			text: root.countUpdates
		}

		CustomText {
			color: root.textColor
			font.pointSize: 12
			text: textMetrics.text
		}
	}
}
