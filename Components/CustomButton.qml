import QtQuick
import QtQuick.Controls

Button {
	id: control

	required property color textColor
	required property color bgColor
	property int radius: 4

	contentItem: CustomText {
		text: control.text

		opacity: control.enabled ? 1.0 : 0.5
		color: control.textColor
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	background: CustomRect {
		opacity: control.enabled ? 1.0 : 0.5

		radius: control.radius
		color: control.bgColor
	}

	StateLayer {
		radius: control.radius
		function onClicked(): void {
			control.clicked();
		}
	}
}
