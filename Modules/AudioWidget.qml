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
	property bool expanded: false
	property color textColor: DynamicColors.palette.m3onSurface

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: expanded ? 300 : 150

	Behavior on implicitWidth {
		NumberAnimation {
			duration: 300
			easing.type: Easing.OutCubic
		}
	}

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		height: 22
		radius: height / 2

		Behavior on color {
			CAnim {
			}
		}

		Rectangle {
			anchors.centerIn: parent
			border.color: "#30ffffff"
			border.width: 0
			color: "transparent"
			height: parent.height
			radius: width / 2
			width: parent.width
		}

		RowLayout {
			anchors {
				fill: parent
				leftMargin: 10
				rightMargin: 15
			}

			MaterialIcon {
				Layout.alignment: Qt.AlignVCenter
				color: Audio.muted ? DynamicColors.palette.m3error : root.textColor
				font.pixelSize: 18
				text: Audio.muted ? "volume_off" : "volume_up"
			}

			Rectangle {
				Layout.fillWidth: true
				color: "#50ffffff"
				implicitHeight: 4
				radius: 20

				Rectangle {
					id: sinkVolumeBar

					color: Audio.muted ? DynamicColors.palette.m3error : root.barColor
					implicitWidth: parent.width * (Audio.volume ?? 0)
					radius: parent.radius

					Behavior on color {
						CAnim {
						}
					}

					anchors {
						bottom: parent.bottom
						left: parent.left
						top: parent.top
					}
				}
			}

			MaterialIcon {
				Layout.alignment: Qt.AlignVCenter
				color: (Audio.sourceMuted ?? false) ? DynamicColors.palette.m3error : root.textColor
				font.pixelSize: 18
				text: Audio.sourceMuted ? "mic_off" : "mic"
			}

			Rectangle {
				Layout.fillWidth: true
				color: "#50ffffff"
				implicitHeight: 4
				radius: 20

				Rectangle {
					id: sourceVolumeBar

					color: (Audio.sourceMuted ?? false) ? DynamicColors.palette.m3error : root.barColor
					implicitWidth: parent.width * (Audio.sourceVolume ?? 0)
					radius: parent.radius

					Behavior on color {
						CAnim {
						}
					}

					anchors {
						bottom: parent.bottom
						left: parent.left
						top: parent.top
					}
				}
			}
		}
	}
}
