import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
	id: root

	background: Item {
		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: parent.top
			bottomRightRadius: root.implicitHeight / 6
			color: DynamicColors.palette.m3primary
			implicitWidth: root.handle.x - root.implicitHeight / 2
			radius: 1000
			topRightRadius: root.implicitHeight / 6
		}

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			anchors.top: parent.top
			bottomLeftRadius: root.implicitHeight / 6
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitWidth: parent.width - root.handle.x - root.handle.implicitWidth - root.implicitHeight / 2
			radius: 1000
			topLeftRadius: root.implicitHeight / 6
		}
	}
	handle: CustomRect {
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.palette.m3primary
		implicitHeight: 15
		implicitWidth: 5
		radius: 1000
		x: root.visualPosition * root.availableWidth - implicitWidth / 2

		MouseArea {
			acceptedButtons: Qt.NoButton
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
		}
	}
}
