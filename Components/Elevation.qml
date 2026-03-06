import qs.Config
import QtQuick
import QtQuick.Effects

RectangularShadow {
	property real dp: [0, 1, 3, 6, 8, 12][level]
	property int level

	blur: (dp * 5) ** 0.7
	color: Qt.alpha(DynamicColors.palette.m3shadow, 0.7)
	offset.y: dp / 2
	spread: -dp * 0.3 + (dp * 0.1) ** 2

	Behavior on dp {
		Anim {
		}
	}
}
