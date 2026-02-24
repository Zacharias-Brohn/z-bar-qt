pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Text {
	id: root

	property bool animate: false
	property int animateDuration: 400
	property real animateFrom: 0
	property string animateProp: "scale"
	property real animateTo: 1

	color: DynamicColors.palette.m3onSurface
	font.family: Appearance.font.family.sans
	font.pointSize: 12
	renderType: Text.NativeRendering
	textFormat: Text.PlainText

	Behavior on color {
		CAnim {
		}
	}
	Behavior on text {
		enabled: root.animate

		SequentialAnimation {
			Anim {
				easing.bezierCurve: MaterialEasing.standardAccel
				to: root.animateFrom
			}

			PropertyAction {
			}

			Anim {
				easing.bezierCurve: MaterialEasing.standardDecel
				to: root.animateTo
			}
		}
	}

	component Anim: NumberAnimation {
		duration: root.animateDuration / 2
		easing.type: Easing.BezierSpline
		properties: root.animateProp.split(",").length > 1 ? root.animateProp : ""
		property: root.animateProp.split(",").length === 1 ? root.animateProp : ""
		target: root
	}
}
