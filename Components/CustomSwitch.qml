import qs.Config
import qs.Modules
import QtQuick
import QtQuick.Templates
import QtQuick.Shapes

Switch {
    id: root

    property int cLayer: 1

    implicitWidth: implicitIndicatorWidth
    implicitHeight: implicitIndicatorHeight

    indicator: CustomRect {
        radius: 1000
        color: root.checked ? DynamicColors.palette.m3primary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, root.cLayer)

        implicitWidth: implicitHeight * 1.7
        implicitHeight: 13 + 7 * 2

        CustomRect {
            readonly property real nonAnimWidth: root.pressed ? implicitHeight * 1.3 : implicitHeight

            radius: 1000
            color: root.checked ? DynamicColors.palette.m3onPrimary : DynamicColors.layer(DynamicColors.palette.m3outline, root.cLayer + 1)

            x: root.checked ? parent.implicitWidth - nonAnimWidth - 10 / 2 : 10 / 2
            implicitWidth: nonAnimWidth
            implicitHeight: parent.implicitHeight - 10
            anchors.verticalCenter: parent.verticalCenter

            CustomRect {
                anchors.fill: parent
                radius: parent.radius

                color: root.checked ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
                opacity: root.pressed ? 0.1 : root.hovered ? 0.08 : 0

                Behavior on opacity {
                    Anim {}
                }
            }

            Behavior on x {
                Anim {}
            }

            Behavior on implicitWidth {
                Anim {}
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: false
    }

    component PropAnim: PropertyAnimation {
		duration: MaterialEasing.expressiveEffectsTime
		easing.bezierCurve: MaterialEasing.expressiveEffects
        easing.type: Easing.BezierSpline
    }
}
