pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons
import qs.Modules as Modules

Item {
    id: root

    required property Brightness.Monitor monitor
    required property var visibilities

    required property real volume
    required property bool muted
    required property real sourceVolume
    required property bool sourceMuted
    required property real brightness

    implicitWidth: layout.implicitWidth + Appearance.padding.small * 2
    implicitHeight: layout.implicitHeight + Appearance.padding.small * 2

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Appearance.spacing.normal

        // Speaker volume
        CustomMouseArea {
            implicitWidth: Config.osd.sizes.sliderWidth
            implicitHeight: Config.osd.sizes.sliderHeight

            function onWheel(event: WheelEvent) {
                if (event.angleDelta.y > 0)
                    Audio.incrementVolume();
                else if (event.angleDelta.y < 0)
                    Audio.decrementVolume();
            }

            FilledSlider {
                anchors.fill: parent

                icon: Icons.getVolumeIcon(value, root.muted)
                value: root.volume
				to: Config.services.maxVolume
                onMoved: Audio.setVolume(value)
            }
        }

        // Microphone volume
        WrappedLoader {
            shouldBeActive: Config.osd.enableMicrophone && (!Config.osd.enableBrightness || !root.visibilities.session)

            sourceComponent: CustomMouseArea {
                implicitWidth: Config.osd.sizes.sliderWidth
                implicitHeight: Config.osd.sizes.sliderHeight

                function onWheel(event: WheelEvent) {
                    if (event.angleDelta.y > 0)
                        Audio.incrementSourceVolume();
                    else if (event.angleDelta.y < 0)
                        Audio.decrementSourceVolume();
                }

                FilledSlider {
                    anchors.fill: parent

                    icon: Icons.getMicVolumeIcon(value, root.sourceMuted)
                    value: root.sourceVolume
                    to: Config.services.maxVolume
					color: Audio.sourceMuted ? DynamicColors.palette.m3error : DynamicColors.palette.m3secondary
                    onMoved: Audio.setSourceVolume(value)
                }
            }
        }

        // Brightness
        WrappedLoader {
            shouldBeActive: Config.osd.enableBrightness

            sourceComponent: CustomMouseArea {
                implicitWidth: Config.osd.sizes.sliderWidth
                implicitHeight: Config.osd.sizes.sliderHeight

                function onWheel(event: WheelEvent) {
                    const monitor = root.monitor;
                    if (!monitor)
                        return;
                    if (event.angleDelta.y > 0)
                        monitor.setBrightness(monitor.brightness + Config.services.brightnessIncrement);
                    else if (event.angleDelta.y < 0)
                        monitor.setBrightness(monitor.brightness - Config.services.brightnessIncrement);
                }

                FilledSlider {
                    anchors.fill: parent

                    icon: `brightness_${(Math.round(value * 6) + 1)}`
                    value: root.brightness
                    onMoved: {
						if ( Config.osd.allMonBrightness ) {
							root.monitor?.setBrightness(value)
						} else {
							for (const mon of Brightness.monitors) {
								mon.setBrightness(value)
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
        opacity: shouldBeActive ? 1 : 0
        active: opacity > 0
        visible: active

        Behavior on Layout.preferredHeight {
            Modules.Anim {
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }

        Behavior on opacity {
            Modules.Anim {}
        }
    }
}
