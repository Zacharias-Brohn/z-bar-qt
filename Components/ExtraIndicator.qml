import qs.Config
import qs.Modules
import QtQuick

CustomRect {
    required property int extra

    anchors.right: parent.right
    anchors.margins: 8

    color: DynamicColors.palette.m3tertiary
    radius: 8

    implicitWidth: count.implicitWidth + 8 * 2
    implicitHeight: count.implicitHeight + 4 * 2

    opacity: extra > 0 ? 1 : 0
    scale: extra > 0 ? 1 : 0.5

    Elevation {
        anchors.fill: parent
        radius: parent.radius
        opacity: parent.opacity
        z: -1
        level: 2
    }

    CustomText {
        id: count

        anchors.centerIn: parent
        animate: parent.opacity > 0
        text: qsTr("+%1").arg(parent.extra)
        color: DynamicColors.palette.m3onTertiary
    }

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
}
