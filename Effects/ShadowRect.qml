import QtQuick
import QtQuick.Effects

Item {
	id: root

	property real radius

	Rectangle {
		id: shadowRect

		anchors.fill: root
		color: "black"
		layer.enabled: true
		radius: root.radius
		visible: false
	}

	MultiEffect {
		id: effects

		anchors.fill: shadowRect
		autoPaddingEnabled: true
		maskEnabled: true
		maskInverted: true
		maskSource: shadowRect
		shadowBlur: 2.0
		shadowColor: "black"
		shadowEnabled: true
		shadowOpacity: 1
		source: shadowRect
	}
}
