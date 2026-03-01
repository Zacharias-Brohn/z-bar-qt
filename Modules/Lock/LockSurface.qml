pragma ComponentBehavior: Bound

import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs.Config
import qs.Helpers
import qs.Components

WlSessionLockSurface {
	id: root

	required property WlSessionLock lock
	required property Pam pam
	readonly property alias unlocking: unlockAnim.running

	color: "transparent"

	Connections {
		function onUnlock(): void {
			unlockAnim.start();
		}

		target: root.lock
	}

	SequentialAnimation {
		id: unlockAnim

		ParallelAnimation {
			Anim {
				duration: Appearance.anim.durations.expressiveDefaultSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
				properties: "implicitWidth,implicitHeight"
				target: lockContent
				to: lockContent.size
			}

			Anim {
				property: "radius"
				target: lockBg
				to: lockContent.radius
			}

			Anim {
				duration: Appearance.anim.durations.expressiveDefaultSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
				property: "scale"
				target: content
				to: 0
			}

			Anim {
				duration: Appearance.anim.durations.small
				property: "opacity"
				target: content
				to: 0
			}

			Anim {
				duration: Appearance.anim.durations.large
				property: "opacity"
				target: lockIcon
				to: 1
			}

			SequentialAnimation {
				PauseAnimation {
					duration: Appearance.anim.durations.small
				}

				Anim {
					property: "opacity"
					target: lockContent
					to: 0
				}
			}
		}

		PropertyAction {
			property: "locked"
			target: root.lock
			value: false
		}
	}

	ParallelAnimation {
		id: initAnim

		running: true

		SequentialAnimation {
			ParallelAnimation {
				Anim {
					duration: Appearance.anim.durations.expressiveFastSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
					property: "scale"
					target: lockContent
					to: 1
				}
			}

			ParallelAnimation {
				Anim {
					property: "opacity"
					target: lockIcon
					to: 0
				}

				Anim {
					property: "opacity"
					target: content
					to: 1
				}

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					property: "scale"
					target: content
					to: 1
				}

				Anim {
					property: "radius"
					target: lockBg
					to: Appearance.rounding.large * 1.5
				}

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					property: "implicitWidth"
					target: lockContent
					to: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult * Config.lock.sizes.ratio
				}

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					property: "implicitHeight"
					target: lockContent
					to: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult
				}
			}
		}
	}

	Image {
		id: background

		anchors.fill: parent
		source: WallpaperPath.lockscreenBg
	}

	Item {
		id: lockContent

		readonly property int radius: size / 4 * Appearance.rounding.scale
		readonly property int size: lockIcon.implicitHeight + Appearance.padding.large * 4

		anchors.centerIn: parent
		implicitHeight: size
		implicitWidth: size
		scale: 0

		// MultiEffect {
		// 	anchors.fill: lockBg
		// 	autoPaddingEnabled: false
		// 	blur: 1
		// 	blurEnabled: true
		// 	blurMax: 64
		// 	maskEnabled: true
		// 	maskSource: lockBg
		//
		// 	source: ShaderEffectSource {
		// 		sourceItem: background
		// 		sourceRect: Qt.rect(lockBg.x, lockBg.y, lockBg.width, lockBg, height)
		// 	}
		// }

		CustomRect {
			id: lockBg

			anchors.fill: parent
			color: DynamicColors.palette.m3surface
			layer.enabled: true
			opacity: DynamicColors.transparency.enabled ? DynamicColors.transparency.base : 1
			radius: lockContent.radius

			layer.effect: MultiEffect {
				blurMax: 15
				shadowColor: Qt.alpha(DynamicColors.palette.m3shadow, 0.7)
				shadowEnabled: true
			}
		}

		MaterialIcon {
			id: lockIcon

			anchors.centerIn: parent
			font.bold: true
			font.pointSize: Appearance.font.size.extraLarge * 4
			text: "lock"
		}

		Content {
			id: content

			anchors.centerIn: parent
			height: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult - Appearance.padding.large * 2
			lock: root
			opacity: 0
			scale: 0
			width: (root.screen?.height ?? 0) * Config.lock.sizes.heightMult * Config.lock.sizes.ratio - Appearance.padding.large * 2
		}
	}
}
