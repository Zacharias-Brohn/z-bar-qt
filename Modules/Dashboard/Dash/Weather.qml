import QtQuick
import qs.Helpers
import qs.Components
import qs.Config

Item {
	id: root

	anchors.centerIn: parent
	implicitWidth: icon.implicitWidth + info.implicitWidth + info.anchors.leftMargin

	Component.onCompleted: Weather.reload()

	MaterialIcon {
		id: icon

		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		animate: true
		color: DynamicColors.palette.m3secondary
		font.pointSize: 54
		text: Weather.icon
	}

	Column {
		id: info

		anchors.left: icon.right
		anchors.leftMargin: Appearance.spacing.large
		anchors.verticalCenter: parent.verticalCenter
		spacing: 8

		CustomText {
			anchors.horizontalCenter: parent.horizontalCenter
			animate: true
			color: DynamicColors.palette.m3primary
			font.pointSize: Appearance.font.size.extraLarge
			font.weight: 500
			text: Weather.temp
		}

		CustomText {
			anchors.horizontalCenter: parent.horizontalCenter
			animate: true
			elide: Text.ElideRight
			text: Weather.description
			width: Math.min(implicitWidth, root.parent.width - icon.implicitWidth - info.anchors.leftMargin - 24 * 2)
		}
	}
}
