import QtQuick
import QtQuick.Controls
import qs.Config

CheckBox {
	id: control

	property int checkWidth: 20
	property int checkHeight: 20

	indicator: CustomRect {
		implicitWidth: control.checkWidth
		implicitHeight: control.checkHeight
		// x: control.leftPadding
		// y: parent.implicitHeight / 2 - implicitHeight / 2
		border.color: control.checked ? DynamicColors.palette.m3primary : "transparent"
		color: DynamicColors.palette.m3surfaceVariant

		radius: 4

		CustomRect {
			implicitWidth: control.checkWidth - (x * 2)
			implicitHeight: control.checkHeight - (y * 2)
			x: 4
			y: 4
			radius: 3
			color: DynamicColors.palette.m3primary
			visible: control.checked
		}
	}

	contentItem: CustomText {
		text: control.text
		font.pointSize: control.font.pointSize
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		anchors.leftMargin: control.checkWidth + control.leftPadding + 8
	}
}
