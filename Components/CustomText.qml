pragma ComponentBehavior: Bound

import QtQuick
import qs.Config
import qs.Modules

Text {
    id: root

    property bool animate: false
    property string animateProp: "scale"
    property real animateFrom: 0
    property real animateTo: 1
    property int animateDuration: 400

    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    color: DynamicColors.palette.m3onSurface
    font.family: Config.baseFont
    font.pointSize: 12

    Behavior on color {
        CAnim {}
    }

    Behavior on text {
        enabled: root.animate

        SequentialAnimation {
            Anim {
                to: root.animateFrom
                easing.bezierCurve: MaterialEasing.standardAccel
            }
            PropertyAction {}
            Anim {
                to: root.animateTo
                easing.bezierCurve: MaterialEasing.standardDecel
            }
        }
    }

    component Anim: NumberAnimation {
        target: root
        property: root.animateProp.split(",").length === 1 ? root.animateProp : ""
        properties: root.animateProp.split(",").length > 1 ? root.animateProp : ""
        duration: root.animateDuration / 2
        easing.type: Easing.BezierSpline
    }
}
