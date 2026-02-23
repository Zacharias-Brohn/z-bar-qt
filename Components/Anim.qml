import QtQuick
import qs.Config

NumberAnimation {
    duration: MaterialEasing.standardTime
    easing.type: Easing.BezierSpline
    easing.bezierCurve: MaterialEasing.standard
}
