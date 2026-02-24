import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components

Item {
	id: root

	property color barColor: DynamicColors.palette.m3primary
	required property string details
	required property string iconString
	required property double percentage
	required property string resourceName
	property color textColor: DynamicColors.palette.m3onSurface
	property color warningBarColor: DynamicColors.palette.m3error
	required property int warningThreshold

	Layout.preferredHeight: columnLayout.implicitHeight
	Layout.preferredWidth: 158

	ColumnLayout {
		id: columnLayout

		anchors.fill: parent
		spacing: 4

		Row {
			Layout.alignment: Qt.AlignLeft
			Layout.fillWidth: true
			spacing: 6

			MaterialIcon {
				color: root.textColor
				font.family: "Material Symbols Rounded"
				font.pointSize: 28
				text: root.iconString
			}

			CustomText {
				anchors.verticalCenter: parent.verticalCenter
				color: root.textColor
				font.pointSize: 12
				text: root.resourceName
			}
		}

		Rectangle {
			Layout.alignment: Qt.AlignLeft
			Layout.fillWidth: true
			Layout.preferredHeight: 6
			color: "#40000000"
			radius: height / 2

			Rectangle {
				color: root.percentage * 100 >= root.warningThreshold ? root.warningBarColor : root.barColor
				height: parent.height
				radius: height / 2
				width: parent.width * Math.min(root.percentage, 1)

				Behavior on width {
					Anim {
						duration: MaterialEasing.expressiveEffectsTime
						easing.bezierCurve: MaterialEasing.expressiveEffects
					}
				}
			}
		}

		CustomText {
			Layout.alignment: Qt.AlignLeft
			color: root.textColor
			font.pointSize: 10
			text: root.details
		}
	}
}
