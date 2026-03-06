import QtQuick
import QtQuick.Controls

Button {
	id: control

	required property color bgColor
	property int radius: 4
	required property color textColor

	background: CustomRect {
		color: control.bgColor
		opacity: control.enabled ? 1.0 : 0.5
		radius: control.radius
	}
	contentItem: CustomText {
		color: control.textColor
		horizontalAlignment: Text.AlignHCenter
		opacity: control.enabled ? 1.0 : 0.5
		text: control.text
		verticalAlignment: Text.AlignVCenter
	}

	StateLayer {
		function onClicked(): void {
			control.clicked();
		}

		radius: control.radius
	}
}
