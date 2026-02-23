import QtQuick
import qs.Modules
import qs.Config

NumberAnimation {
    duration: MaterialEasing.standardTime
    easing.type: Easing.BezierSpline
    easing.bezierCurve: MaterialEasing.standard
}
