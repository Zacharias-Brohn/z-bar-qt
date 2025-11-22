import QtQuick
import qs.Modules

ColorAnimation {
    duration: 400
    easing.type: Easing.BezierSpline
    easing.bezierCurve: MaterialEasing.standard
}
