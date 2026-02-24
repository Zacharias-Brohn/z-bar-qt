import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property real horizontalPadding: 10
	property bool isVisible: backgroundRectangle.implicitHeight > 0
	property bool shown: false
	required property string text
	property real verticalPadding: 5

	implicitHeight: tooltipTextObject.implicitHeight + 2 * root.verticalPadding
	implicitWidth: tooltipTextObject.implicitWidth + 2 * root.horizontalPadding

	Rectangle {
		id: backgroundRectangle

		clip: true
		color: DynamicColors.tPalette.m3inverseSurface ?? "#3C4043"
		implicitHeight: shown ? (tooltipTextObject.implicitHeight + 2 * root.verticalPadding) : 0
		implicitWidth: shown ? (tooltipTextObject.implicitWidth + 2 * root.horizontalPadding) : 0
		opacity: shown ? 1 : 0
		radius: 8

		Behavior on implicitHeight {
			Anim {
			}
		}
		Behavior on implicitWidth {
			Anim {
			}
		}
		Behavior on opacity {
			Anim {
			}
		}

		anchors {
			bottom: root.bottom
			horizontalCenter: root.horizontalCenter
		}

		CustomText {
			id: tooltipTextObject

			anchors.centerIn: parent
			color: DynamicColors.palette.m3inverseOnSurface ?? "#FFFFFF"
			text: root.text
			wrapMode: Text.Wrap
		}
	}
}
