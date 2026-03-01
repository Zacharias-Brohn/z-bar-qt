pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property var lock

	anchors.fill: parent

	Image {
		anchors.fill: parent
		asynchronous: true
		fillMode: Image.PreserveAspectCrop
		layer.enabled: true
		opacity: status === Image.Ready ? 1 : 0
		source: Players.active?.trackArtUrl ?? ""
		sourceSize.height: height
		sourceSize.width: width

		layer.effect: OpacityMask {
			maskSource: mask
		}
		Behavior on opacity {
			Anim {
				duration: Appearance.anim.durations.extraLarge
			}
		}
	}

	Rectangle {
		id: mask

		anchors.fill: parent
		layer.enabled: true
		visible: false

		gradient: Gradient {
			orientation: Gradient.Horizontal

			GradientStop {
				color: Qt.rgba(0, 0, 0, 0.5)
				position: 0
			}

			GradientStop {
				color: Qt.rgba(0, 0, 0, 0.2)
				position: 0.4
			}

			GradientStop {
				color: Qt.rgba(0, 0, 0, 0)
				position: 0.8
			}
		}
	}

	ColumnLayout {
		id: layout

		anchors.fill: parent
		anchors.margins: Appearance.padding.large

		CustomText {
			Layout.bottomMargin: Appearance.spacing.larger
			Layout.topMargin: Appearance.padding.large
			color: DynamicColors.palette.m3onSurfaceVariant
			font.family: Appearance.font.family.mono
			font.weight: 500
			text: qsTr("Now playing")
		}

		CustomText {
			Layout.fillWidth: true
			animate: true
			color: DynamicColors.palette.m3primary
			elide: Text.ElideRight
			font.family: Appearance.font.family.mono
			font.pointSize: Appearance.font.size.large
			font.weight: 600
			horizontalAlignment: Text.AlignHCenter
			text: Players.active?.trackArtist ?? qsTr("No media")
		}

		CustomText {
			Layout.fillWidth: true
			animate: true
			elide: Text.ElideRight
			font.family: Appearance.font.family.mono
			font.pointSize: Appearance.font.size.larger
			horizontalAlignment: Text.AlignHCenter
			text: Players.active?.trackTitle ?? qsTr("No media")
		}

		RowLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: Appearance.padding.large
			Layout.topMargin: Appearance.spacing.large * 1.2
			spacing: Appearance.spacing.large

			PlayerControl {
				function onClicked(): void {
					if (Players.active?.canGoPrevious)
						Players.active.previous();
				}

				icon: "skip_previous"
			}

			PlayerControl {
				function onClicked(): void {
					if (Players.active?.canTogglePlaying)
						Players.active.togglePlaying();
				}

				active: Players.active?.isPlaying ?? false
				animate: true
				icon: active ? "pause" : "play_arrow"
				level: active ? 2 : 1
				set_color: "Primary"
			}

			PlayerControl {
				function onClicked(): void {
					if (Players.active?.canGoNext)
						Players.active.next();
				}

				icon: "skip_next"
			}
		}
	}

	component PlayerControl: CustomRect {
		id: control

		property bool active
		property alias animate: controlIcon.animate
		property alias icon: controlIcon.text
		property int level: 1
		property string set_color: "Secondary"

		function onClicked(): void {
		}

		Layout.preferredWidth: implicitWidth + (controlState.pressed ? Appearance.padding.normal * 2 : active ? Appearance.padding.small * 2 : 0)
		color: active ? DynamicColors.palette[`m3${set_color.toLowerCase()}`] : DynamicColors.palette[`m3${set_color.toLowerCase()}Container`]
		implicitHeight: controlIcon.implicitHeight + Appearance.padding.normal * 2
		implicitWidth: controlIcon.implicitWidth + Appearance.padding.large * 2
		radius: active || controlState.pressed ? Appearance.rounding.small : Appearance.rounding.normal

		Behavior on Layout.preferredWidth {
			Anim {
				duration: Appearance.anim.durations.expressiveFastSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
			}
		}
		Behavior on radius {
			Anim {
				duration: Appearance.anim.durations.expressiveFastSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
			}
		}

		Elevation {
			anchors.fill: parent
			level: controlState.containsMouse && !controlState.pressed ? control.level + 1 : control.level
			radius: parent.radius
			z: -1
		}

		StateLayer {
			id: controlState

			function onClicked(): void {
				control.onClicked();
			}

			color: control.active ? DynamicColors.palette[`m3on${control.colour}`] : DynamicColors.palette[`m3on${control.colour}Container`]
		}

		MaterialIcon {
			id: controlIcon

			anchors.centerIn: parent
			color: control.active ? DynamicColors.palette[`m3on${control.colour}`] : DynamicColors.palette[`m3on${control.colour}Container`]
			fill: control.active ? 1 : 0
			font.pointSize: Appearance.font.size.large

			Behavior on fill {
				Anim {
				}
			}
		}
	}
}
