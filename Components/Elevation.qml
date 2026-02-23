import qs.Config
import QtQuick
import QtQuick.Effects

RectangularShadow {
    property int level
    property real dp: [0, 1, 3, 6, 8, 12][level]

    color: Qt.alpha(DynamicColors.palette.m3shadow, 0.7)
    blur: (dp * 5) ** 0.7
    spread: -dp * 0.3 + (dp * 0.1) ** 2
    offset.y: dp / 2

    Behavior on dp {
        Anim {}
    }
}
