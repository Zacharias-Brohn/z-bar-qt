import ZShell.Services
import QtQuick
import QtQuick.Shapes
import qs.Daemons
import qs.Components
import qs.Config
import qs.Helpers
import qs.Modules
import qs.Paths

Item {
	id: root

	property real playerProgress: {
		const active = Players.active;
		return active?.length ? active.position / active.length : 0;
	}

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: Config.dashboard.sizes.mediaWidth

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

	ServiceRef {
		service: Audio.beatTracker
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

	CustomClippingRect {
		id: cover

		anchors.left: parent.left
		anchors.margins: Appearance.padding.large + Config.dashboard.sizes.mediaProgressThickness + Appearance.spacing.small
		anchors.right: parent.right
		anchors.top: parent.top
		color: DynamicColors.tPalette.m3surfaceContainerHigh
		implicitHeight: width
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
			sourceSize.height: height
			sourceSize.width: width
		}
	}

	CustomText {
		id: title

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: cover.bottom
		anchors.topMargin: Appearance.spacing.normal
		animate: true
		color: DynamicColors.palette.m3primary
		elide: Text.ElideRight
		font.pointSize: Appearance.font.size.normal
		horizontalAlignment: Text.AlignHCenter
		text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
		width: parent.implicitWidth - Appearance.padding.large * 2
	}

	CustomText {
		id: album

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: title.bottom
		anchors.topMargin: Appearance.spacing.small
		animate: true
		color: DynamicColors.palette.m3outline
		elide: Text.ElideRight
		font.pointSize: Appearance.font.size.small
		horizontalAlignment: Text.AlignHCenter
		text: (Players.active?.trackAlbum ?? qsTr("No media")) || qsTr("Unknown album")
		width: parent.implicitWidth - Appearance.padding.large * 2
	}

	CustomText {
		id: artist

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: album.bottom
		anchors.topMargin: Appearance.spacing.small
		animate: true
		color: DynamicColors.palette.m3secondary
		elide: Text.ElideRight
		horizontalAlignment: Text.AlignHCenter
		text: (Players.active?.trackArtist ?? qsTr("No media")) || qsTr("Unknown artist")
		width: parent.implicitWidth - Appearance.padding.large * 2
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
