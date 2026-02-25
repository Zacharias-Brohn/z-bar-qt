pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Daemons
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	property real playerProgress: {
		const active = Players.active;
		return active?.length ? active.position / active.length : 0;
	}
	property int rowHeight: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: cover.height + rowHeight * 2

	Behavior on playerProgress {
		Anim {
			duration: Appearance.anim.durations.large
		}
	}

	Timer {
		interval: Config.dashboard.mediaUpdateInterval
		repeat: true
		running: Players.active?.isPlaying ?? false
		triggeredOnStart: true

		onTriggered: Players.active?.positionChanged()
	}

	Shape {
		id: visualizer

		readonly property real centerX: width / 2
		readonly property real centerY: height / 2
		property color colour: DynamicColors.palette.m3primary
		readonly property real innerX: cover.implicitWidth / 2 + Appearance.spacing.small
		readonly property real innerY: cover.implicitHeight / 2 + Appearance.spacing.small

		anchors.fill: cover
		anchors.margins: -Config.dashboard.sizes.mediaVisualiserSize
		asynchronous: true
		data: visualizerBars.instances
		preferredRendererType: Shape.CurveRenderer
	}

	Variants {
		id: visualizerBars

		model: Array.from({
			length: Config.services.visualizerBars
		}, (_, i) => i)

		ShapePath {
			id: visualizerBar

			readonly property real angle: modelData * 2 * Math.PI / Config.services.visualizerBars
			readonly property real cos: Math.cos(angle)
			readonly property real magnitude: value * Config.dashboard.sizes.mediaVisualiserSize
			required property int modelData
			readonly property real sin: Math.sin(angle)
			readonly property real value: Math.max(1e-3, Math.min(1, Audio.cava.values[modelData]))

			capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
			startX: visualizer.centerX + (visualizer.innerX + strokeWidth / 2) * cos
			strokeColor: DynamicColors.palette.m3primary
			strokeWidth: 360 / Config.services.visualizerBars - Appearance.spacing.small / 4

			startY: PathLine {
				x: visualizer.centerX + (visualizer.innerX + visualizerBar.strokeWidth / 2 + visualizerBar.magnitude) * visualizerBar.cos
				y: visualizer.centerY + (visualizer.innerY + visualizerBar.strokeWidth / 2 + visualizerBar.magnitude) * visualizerBar.sin
			}
			Behavior on strokeColor {
				CAnim {
				}
			}
		}
	}

	Shape {
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
			fillColor: "transparent"
			strokeColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
			strokeWidth: Config.dashboard.sizes.mediaProgressThickness

			Behavior on strokeColor {
				CAnim {
				}
			}

			PathAngleArc {
				centerX: cover.x + cover.width / 2
				centerY: cover.y + cover.height / 2
				radiusX: (cover.width + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				radiusY: (cover.height + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				startAngle: -90 - Config.dashboard.sizes.mediaProgressSweep / 2
				sweepAngle: Config.dashboard.sizes.mediaProgressSweep
			}
		}

		ShapePath {
			capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
			fillColor: "transparent"
			strokeColor: DynamicColors.palette.m3primary
			strokeWidth: Config.dashboard.sizes.mediaProgressThickness

			Behavior on strokeColor {
				CAnim {
				}
			}

			PathAngleArc {
				centerX: cover.x + cover.width / 2
				centerY: cover.y + cover.height / 2
				radiusX: (cover.width + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				radiusY: (cover.height + Config.dashboard.sizes.mediaProgressThickness) / 2 + Appearance.spacing.small
				startAngle: -90 - Config.dashboard.sizes.mediaProgressSweep / 2
				sweepAngle: Config.dashboard.sizes.mediaProgressSweep * root.playerProgress
			}
		}
	}

	RowLayout {
		id: layout

		anchors.left: parent.left
		anchors.right: parent.right
		implicitHeight: root.implicitHeight

		CustomClippingRect {
			id: cover

			Layout.alignment: Qt.AlignLeft
			Layout.bottomMargin: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
			Layout.leftMargin: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
			Layout.preferredHeight: Config.dashboard.sizes.mediaCoverArtSize
			Layout.preferredWidth: Config.dashboard.sizes.mediaCoverArtSize
			Layout.topMargin: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
			color: DynamicColors.tPalette.m3surfaceContainerHigh
			radius: Infinity

			MaterialIcon {
				anchors.centerIn: parent
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: (parent.width * 0.4) || 1
				grade: 200
				text: "art_track"
			}

			Image {
				id: image

				anchors.fill: parent
				asynchronous: true
				fillMode: Image.PreserveAspectCrop
				source: Players.active?.trackArtUrl ?? ""
				sourceSize.height: Math.floor(height)
				sourceSize.width: Math.floor(width)
			}
		}

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height

			MarqueeText {
				id: title

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				color: DynamicColors.palette.m3primary
				font.pointSize: Appearance.font.size.normal
				horizontalAlignment: Text.AlignHCenter
				pauseMs: 4000
				text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
				width: parent.width - Appearance.padding.large * 4
			}

			MarqueeText {
				id: album

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: title.bottom
				anchors.topMargin: Appearance.spacing.small
				color: DynamicColors.palette.m3outline
				font.pointSize: Appearance.font.size.small
				horizontalAlignment: Text.AlignHCenter
				pauseMs: 4000
				text: (Players.active?.trackAlbum ?? qsTr("No media")) || qsTr("Unknown album")
				width: parent.width - Appearance.padding.large * 4
			}

			MarqueeText {
				id: artist

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: album.bottom
				anchors.topMargin: Appearance.spacing.small
				color: DynamicColors.palette.m3secondary
				horizontalAlignment: Text.AlignHCenter
				pauseMs: 4000
				text: (Players.active?.trackArtist ?? qsTr("No media")) || qsTr("Unknown artist")
				width: parent.width - Appearance.padding.large * 4
			}

			Row {
				id: controls

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: artist.bottom
				anchors.topMargin: Appearance.spacing.smaller
				spacing: Appearance.spacing.small

				Control {
					function onClicked(): void {
						Players.active?.previous();
					}

					canUse: Players.active?.canGoPrevious ?? false
					icon: "skip_previous"
				}

				Control {
					function onClicked(): void {
						Players.active?.togglePlaying();
					}

					canUse: Players.active?.canTogglePlaying ?? false
					icon: Players.active?.isPlaying ? "pause" : "play_arrow"
				}

				Control {
					function onClicked(): void {
						Players.active?.next();
					}

					canUse: Players.active?.canGoNext ?? false
					icon: "skip_next"
				}
			}
		}
	}

	component Control: CustomRect {
		id: control

		required property bool canUse
		required property string icon

		function onClicked(): void {
		}

		implicitHeight: implicitWidth
		implicitWidth: Math.max(icon.implicitHeight, icon.implicitHeight) + Appearance.padding.small

		StateLayer {
			function onClicked(): void {
				control.onClicked();
			}

			disabled: !control.canUse
			radius: Appearance.rounding.full
		}

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			anchors.verticalCenterOffset: font.pointSize * 0.05
			animate: true
			color: control.canUse ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
			font.pointSize: Appearance.font.size.large
			text: control.icon
		}
	}
}
