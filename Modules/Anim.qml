import QtQuick
import qs.Modules

NumberAnimation {
    duration: 400
    easing.type: Easing.BezierSpline
    easing.bezierCurve: MaterialEasing.standard
}
