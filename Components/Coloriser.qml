import QtQuick
import QtQuick.Effects

MultiEffect {
	property color sourceColor: "black"

	brightness: 1 - sourceColor.hslLightness
	colorization: 1

	Behavior on colorizationColor {
		CAnim {
		}
	}
}
