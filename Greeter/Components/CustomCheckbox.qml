import QtQuick
import QtQuick.Controls
import qs.Config

CheckBox {
	id: control

	property int checkHeight: 20
	property int checkWidth: 20

	contentItem: CustomText {
		anchors.left: parent.left
		anchors.leftMargin: control.checkWidth + control.leftPadding + 8
		anchors.verticalCenter: parent.verticalCenter
		font.pointSize: control.font.pointSize
		text: control.text
	}
	indicator: CustomRect {
		// x: control.leftPadding
		// y: parent.implicitHeight / 2 - implicitHeight / 2
		border.color: control.checked ? DynamicColors.palette.m3primary : "transparent"
		color: DynamicColors.palette.m3surfaceVariant
		implicitHeight: control.checkHeight
		implicitWidth: control.checkWidth
		radius: 4

		CustomRect {
			color: DynamicColors.palette.m3primary
			implicitHeight: control.checkHeight - (y * 2)
			implicitWidth: control.checkWidth - (x * 2)
			radius: 3
			visible: control.checked
			x: 4
			y: 4
		}
	}
}
