import QtQuick
import QtQuick.Templates
import qs.Config

RadioButton {
	id: root

	font.pointSize: 12
	implicitHeight: Math.max(implicitIndicatorHeight, implicitContentHeight)
	implicitWidth: implicitIndicatorWidth + implicitContentWidth + contentItem.anchors.leftMargin

	contentItem: CustomText {
		anchors.left: outerCircle.right
		anchors.leftMargin: 10
		anchors.verticalCenter: parent.verticalCenter
		font.pointSize: root.font.pointSize
		text: root.text
	}
	indicator: Rectangle {
		id: outerCircle

		anchors.verticalCenter: parent.verticalCenter
		border.color: root.checked ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
		border.width: 2
		color: "transparent"
		implicitHeight: 16
		implicitWidth: 16
		radius: 1000

		Behavior on border.color {
			CAnim {
			}
		}

		StateLayer {
			function onClicked(): void {
				root.click();
			}

			anchors.margins: -7
			color: root.checked ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3primary
			z: -1
		}

		CustomRect {
			anchors.centerIn: parent
			color: Qt.alpha(DynamicColors.palette.m3primary, root.checked ? 1 : 0)
			implicitHeight: 8
			implicitWidth: 8
			radius: 1000
		}
	}
}
