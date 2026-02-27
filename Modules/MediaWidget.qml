import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Daemons
import qs.Config
import qs.Helpers

Item {
	id: root

	readonly property string currentMedia: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
	readonly property int textWidth: Math.min(metrics.width, 200)

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: layout.implicitWidth + Appearance.padding.normal * 2

	Behavior on implicitWidth {
		Anim {
		}
	}

	CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 22
		radius: Appearance.rounding.full
	}

	TextMetrics {
		id: metrics

		font: mediatext.font
		text: mediatext.text
	}

	RowLayout {
		id: layout

		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.left: parent.left
		anchors.leftMargin: Appearance.padding.normal
		anchors.top: parent.top

		Behavior on implicitWidth {
			Anim {
			}
		}

		MaterialIcon {
			animate: true
			color: Players.active?.isPlaying ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
			font.pointSize: 14
			text: Players.active?.isPlaying ? "music_note" : "music_off"
		}

		MarqueeText {
			id: mediatext

			Layout.preferredWidth: root.textWidth
			animate: true
			color: Players.active?.isPlaying ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
			font.pointSize: Appearance.font.size.normal
			horizontalAlignment: Text.AlignHCenter
			marqueeEnabled: false
			pauseMs: 4000
			text: root.currentMedia
			width: root.textWidth

			CustomMouseArea {
				anchors.fill: parent
				hoverEnabled: true

				onContainsMouseChanged: {
					if (!containsMouse) {
						mediatext.marqueeEnabled = false;
					} else {
						mediatext.marqueeEnabled = true;
						mediatext.anim.start();
					}
				}
			}
		}
	}
}
