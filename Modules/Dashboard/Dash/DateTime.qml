pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: 110

	ColumnLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: 0

		CustomText {
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: -(font.pointSize * 0.4)
			color: DynamicColors.palette.m3secondary
			font.family: "Rubik"
			font.pointSize: 18
			font.weight: 600
			text: Time.hourStr
		}

		CustomText {
			Layout.alignment: Qt.AlignHCenter
			color: DynamicColors.palette.m3primary
			font.family: "Rubik"
			font.pointSize: 18 * 0.9
			text: "•••"
		}

		CustomText {
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: -(font.pointSize * 0.4)
			color: DynamicColors.palette.m3secondary
			font.family: "Rubik"
			font.pointSize: 18
			font.weight: 600
			text: Time.minuteStr
		}
	}
}
