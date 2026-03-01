import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Daemons
import qs.Modules
import qs.Config
import qs.Components

Item {
	id: root

	property color barColor: DynamicColors.palette.m3primary
	property color textColor: DynamicColors.palette.m3onSurface

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: 150

	Behavior on implicitWidth {
		NumberAnimation {
			duration: 300
			easing.type: Easing.OutCubic
		}
	}

	CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		height: 22
		radius: height / 2
	}

	RowLayout {
		id: layout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.small
		anchors.rightMargin: Appearance.padding.small * 2
		anchors.verticalCenter: parent.verticalCenter

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			animate: true
			color: Audio.muted ? DynamicColors.palette.m3error : root.textColor
			font.pointSize: 14
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
			font.pointSize: 14
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
