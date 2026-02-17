pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.Config
import qs.Helpers
import qs.Effects
import qs.Components
import qs.Modules as Modules

WlSessionLockSurface {
    id: root

    required property WlSessionLock lock
    required property Pam pam

    readonly property alias unlocking: unlockAnim.running

    color: "transparent"

    Connections {
        target: root.lock

        function onUnlock(): void {
            unlockAnim.start();
        }
    }

    SequentialAnimation {
        id: unlockAnim

        ParallelAnimation {
            Modules.Anim {
                target: lockContent
                properties: "implicitWidth,implicitHeight"
                to: lockContent.size
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
            Modules.Anim {
                target: lockBg
                property: "radius"
                to: lockContent.radius
            }
            Modules.Anim {
                target: content
                property: "scale"
                to: 0
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
            Modules.Anim {
                target: content
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.small
            }
            Modules.Anim {
                target: lockIcon
                property: "opacity"
                to: 1
                duration: Appearance.anim.durations.large
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: Appearance.anim.durations.small
                }
                Modules.Anim {
                    target: lockContent
                    property: "opacity"
                    to: 0
                }
            }
        }
        PropertyAction {
            target: root.lock
            property: "locked"
            value: false
        }
    }

    ParallelAnimation {
        id: initAnim

        running: true

        SequentialAnimation {
            ParallelAnimation {
                Modules.Anim {
                    target: lockContent
                    property: "scale"
                    to: 1
                    duration: Appearance.anim.durations.expressiveFastSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
                }
            }
            ParallelAnimation {
                Modules.Anim {
                    target: lockIcon
                    property: "opacity"
                    to: 0
                }
                Modules.Anim {
                    target: content
                    property: "opacity"
                    to: 1
                }
                Modules.Anim {
                    target: content
                    property: "scale"
                    to: 1
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
                Modules.Anim {
                    target: lockBg
                    property: "radius"
                    to: Appearance.rounding.large * 1.5
                }
                Modules.Anim {
                    target: lockContent
                    property: "implicitWidth"
                    to: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult * Config.lock.sizes.ratio
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
                Modules.Anim {
                    target: lockContent
                    property: "implicitHeight"
                    to: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }
        }
    }

	CachingImage {
		id: background
		anchors.fill: parent
		asynchronous: true
		path: WallpaperPath.currentWallpaperPath
		opacity: 1

		Component.onCompleted: {
			console.log(path);
		}
	}

    Item {
        id: lockContent

        readonly property int size: lockIcon.implicitHeight + Appearance.padding.large * 4
        readonly property int radius: size / 4 * Appearance.rounding.scale

        anchors.centerIn: parent
        implicitWidth: size
        implicitHeight: size

        scale: 0

        CustomRect {
            id: lockBg

            anchors.fill: parent
            color: DynamicColors.palette.m3surface
			radius: lockContent.radius
            opacity: DynamicColors.transparency.enabled ? DynamicColors.transparency.base : 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(DynamicColors.palette.m3shadow, 0.7)
            }
        }

        MaterialIcon {
            id: lockIcon

            anchors.centerIn: parent
            text: "lock"
            font.pointSize: Appearance.font.size.extraLarge * 4
            font.bold: true
        }

        Content {
            id: content

            anchors.centerIn: parent
            width: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult * Config.lock.sizes.ratio - Appearance.padding.large * 2
            height: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult - Appearance.padding.large * 2

            lock: root
            opacity: 0
            scale: 0
        }
    }
}
