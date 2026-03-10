import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Daemons
import qs.Modules
import qs.Config
import qs.Components

CustomRect {
	id: root

	property color barColor: DynamicColors.palette.m3primary
	property color textColor: DynamicColors.palette.m3onSurface

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: 150
	radius: Appearance.rounding.full

	Behavior on implicitWidth {
		NumberAnimation {
			duration: 300
			easing.type: Easing.OutCubic
		}
	}

	Component.onCompleted: console.log(root.height, root.implicitHeight)

	RowLayout {
		id: layout

		anchors.left: parent.left
		anchors.leftMargin: Appearance.padding.small
		anchors.verticalCenter: parent.verticalCenter
		width: root.implicitWidth - Appearance.padding.small * 3

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			animate: true
			color: Audio.muted ? DynamicColors.palette.m3error : root.textColor
			font.pointSize: Appearance.font.size.larger
			text: Audio.muted ? "volume_off" : "volume_up"
		}

		CustomRect {
			Layout.fillWidth: true
			color: "#50ffffff"
			implicitHeight: 4
			radius: 20

			CustomRect {
				id: sinkVolumeBar

				color: Audio.muted ? DynamicColors.palette.m3error : root.barColor
				implicitWidth: parent.width * (Audio.volume ?? 0)
				radius: parent.radius

				anchors {
					bottom: parent.bottom
					left: parent.left
					top: parent.top
				}
			}
		}

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			animate: true
			color: (Audio.sourceMuted ?? false) ? DynamicColors.palette.m3error : root.textColor
			font.pointSize: Appearance.font.size.larger
			text: Audio.sourceMuted ? "mic_off" : "mic"
		}

		CustomRect {
			Layout.fillWidth: true
			color: "#50ffffff"
			implicitHeight: 4
			radius: 20

			CustomRect {
				id: sourceVolumeBar

				color: (Audio.sourceMuted ?? false) ? DynamicColors.palette.m3error : root.barColor
				implicitWidth: parent.width * (Audio.sourceVolume ?? 0)
				radius: parent.radius

				anchors {
					bottom: parent.bottom
					left: parent.left
					top: parent.top
				}
			}
		}
	}
}
