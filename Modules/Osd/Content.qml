pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

Item {
	id: root

	required property real brightness
	required property Brightness.Monitor monitor
	required property bool muted
	required property bool sourceMuted
	required property real sourceVolume
	required property var visibilities
	required property real volume

	implicitHeight: layout.implicitHeight + Appearance.padding.small * 2
	implicitWidth: layout.implicitWidth + Appearance.padding.small * 2

	ColumnLayout {
		id: layout

		anchors.centerIn: parent
		spacing: Appearance.spacing.normal

		// Speaker volume
		CustomMouseArea {
			function onWheel(event: WheelEvent) {
				if (event.angleDelta.y > 0)
					Audio.incrementVolume();
				else if (event.angleDelta.y < 0)
					Audio.decrementVolume();
			}

			implicitHeight: Config.osd.sizes.sliderHeight
			implicitWidth: Config.osd.sizes.sliderWidth

			FilledSlider {
				anchors.fill: parent
				color: Audio.muted ? DynamicColors.palette.m3error : DynamicColors.palette.m3secondary
				icon: Icons.getVolumeIcon(value, root.muted)
				to: Config.services.maxVolume
				value: root.volume

				onMoved: Audio.setVolume(value)
			}
		}

		// Microphone volume
		WrappedLoader {
			shouldBeActive: Config.osd.enableMicrophone && (!Config.osd.enableBrightness || !root.visibilities.session)

			sourceComponent: CustomMouseArea {
				function onWheel(event: WheelEvent) {
					if (event.angleDelta.y > 0)
						Audio.incrementSourceVolume();
					else if (event.angleDelta.y < 0)
						Audio.decrementSourceVolume();
				}

				implicitHeight: Config.osd.sizes.sliderHeight
				implicitWidth: Config.osd.sizes.sliderWidth

				FilledSlider {
					anchors.fill: parent
					color: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3secondary
					icon: Icons.getMicVolumeIcon(value, root.sourceMuted)
					to: Config.services.maxVolume
					value: root.sourceVolume

					onMoved: Audio.setSourceVolume(value)
				}
			}
		}

		// Brightness
		WrappedLoader {
			shouldBeActive: Config.osd.enableBrightness

			sourceComponent: CustomMouseArea {
				function onWheel(event: WheelEvent) {
					const monitor = root.monitor;
					if (!monitor)
						return;
					if (event.angleDelta.y > 0)
						monitor.setBrightness(monitor.brightness + Config.services.brightnessIncrement);
					else if (event.angleDelta.y < 0)
						monitor.setBrightness(monitor.brightness - Config.services.brightnessIncrement);
				}

				implicitHeight: Config.osd.sizes.sliderHeight
				implicitWidth: Config.osd.sizes.sliderWidth

				FilledSlider {
					anchors.fill: parent
					icon: `brightness_${(Math.round(value * 6) + 1)}`
					value: root.brightness

					onMoved: {
						if (Config.osd.allMonBrightness) {
							root.monitor?.setBrightness(value);
						} else {
							for (const mon of Brightness.monitors) {
								mon.setBrightness(value);
							}
						}
					}
				}
			}
		}
	}

	component WrappedLoader: Loader {
		required property bool shouldBeActive

		Layout.preferredHeight: shouldBeActive ? Config.osd.sizes.sliderHeight : 0
		active: opacity > 0
		opacity: shouldBeActive ? 1 : 0
		visible: active

		Behavior on Layout.preferredHeight {
			Anim {
				easing.bezierCurve: Appearance.anim.curves.emphasized
			}
		}
		Behavior on opacity {
			Anim {
			}
		}
	}
}
