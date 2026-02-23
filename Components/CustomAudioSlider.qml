import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
    id: root

	required property real peak
	property color nonPeakColor: DynamicColors.tPalette.m3primary
	property color peakColor: DynamicColors.palette.m3primary

    background: Item {
        CustomRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            implicitWidth: root.handle.x - root.implicitHeight

            color: root.nonPeakColor
            radius: 1000
            topRightRadius: root.implicitHeight / 15
            bottomRightRadius: root.implicitHeight / 15

			CustomRect {
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.left: parent.left

				implicitWidth: parent.width * root.peak
				radius: 1000
				topRightRadius: root.implicitHeight / 15
				bottomRightRadius: root.implicitHeight / 15

				color: root.peakColor

				Behavior on implicitWidth {
					Anim { duration: 50 }
				}
			}
        }

        CustomRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            implicitWidth: root.implicitWidth - root.handle.x - root.handle.implicitWidth - root.implicitHeight

			Component.onCompleted: {
				console.log(root.handle.x, implicitWidth)
			}


            color: DynamicColors.tPalette.m3surfaceContainer
            radius: 1000
            topLeftRadius: root.implicitHeight / 15
            bottomLeftRadius: root.implicitHeight / 15
        }
    }

    handle: CustomRect {
        x: root.visualPosition * root.availableWidth - implicitWidth / 2

        implicitWidth: 5
        implicitHeight: 15
        anchors.verticalCenter: parent.verticalCenter

        color: DynamicColors.palette.m3primary
        radius: 1000

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
