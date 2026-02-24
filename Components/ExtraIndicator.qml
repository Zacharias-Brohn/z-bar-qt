import qs.Config
import QtQuick

CustomRect {
	required property int extra

	anchors.margins: 8
	anchors.right: parent.right
	color: DynamicColors.palette.m3tertiary
	implicitHeight: count.implicitHeight + 4 * 2
	implicitWidth: count.implicitWidth + 8 * 2
	opacity: extra > 0 ? 1 : 0
	radius: 8
	scale: extra > 0 ? 1 : 0.5

	Behavior on opacity {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
		}
	}
	Behavior on scale {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	Elevation {
		anchors.fill: parent
		level: 2
		opacity: parent.opacity
		radius: parent.radius
		z: -1
	}

	CustomText {
		id: count

		anchors.centerIn: parent
		animate: parent.opacity > 0
		color: DynamicColors.palette.m3onTertiary
		text: qsTr("+%1").arg(parent.extra)
	}
}
