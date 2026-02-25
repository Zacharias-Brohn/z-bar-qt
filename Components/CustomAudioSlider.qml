import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
	id: root

	property color nonPeakColor: DynamicColors.tPalette.m3primary
	required property real peak
	property color peakColor: DynamicColors.palette.m3primary

	background: Item {
		CustomRect {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: root.implicitHeight / 3
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.topMargin: root.implicitHeight / 3
			bottomRightRadius: root.implicitHeight / 15
			color: root.nonPeakColor
			implicitWidth: root.handle.x - root.implicitHeight
			radius: 1000
			topRightRadius: root.implicitHeight / 15

			CustomRect {
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.top: parent.top
				bottomRightRadius: root.implicitHeight / 15
				color: root.peakColor
				implicitWidth: parent.width * root.peak
				radius: 1000
				topRightRadius: root.implicitHeight / 15

				Behavior on implicitWidth {
					Anim {
						duration: 50
					}
				}
			}
		}

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.bottomMargin: root.implicitHeight / 3
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.topMargin: root.implicitHeight / 3
			bottomLeftRadius: root.implicitHeight / 15
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitWidth: root.implicitWidth - root.handle.x - root.handle.implicitWidth - root.implicitHeight
			radius: 1000
			topLeftRadius: root.implicitHeight / 15
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
