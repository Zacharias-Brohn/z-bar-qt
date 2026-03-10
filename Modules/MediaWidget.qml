import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Daemons
import qs.Config
import qs.Helpers

CustomRect {
	id: root

	readonly property string currentMedia: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
	readonly property int textWidth: Math.min(metrics.width, 200)

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: layout.implicitWidth + Appearance.padding.normal * 2
	radius: Appearance.rounding.full

	Behavior on implicitWidth {
		Anim {
		}
	}

	TextMetrics {
		id: metrics

		font: mediatext.font
		text: mediatext.text
	}

	RowLayout {
		id: layout

		anchors.centerIn: parent

		Behavior on implicitWidth {
			Anim {
			}
		}

		MaterialIcon {
			animate: true
			color: Players.active?.isPlaying ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
			font.pointSize: Appearance.font.size.normal
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
