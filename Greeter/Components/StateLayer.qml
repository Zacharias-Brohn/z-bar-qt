import qs.Config
import QtQuick

MouseArea {
	id: root

	property color color: DynamicColors.palette.m3onSurface
	property bool disabled
	property real radius: parent?.radius ?? 0
	property alias rect: hoverLayer

	function onClicked(): void {
	}

	anchors.fill: parent
	cursorShape: disabled ? undefined : Qt.PointingHandCursor
	enabled: !disabled
	hoverEnabled: true

	onClicked: event => !disabled && onClicked(event)
	onPressed: event => {
		if (disabled)
			return;

		rippleAnim.x = event.x;
		rippleAnim.y = event.y;

		const dist = (ox, oy) => ox * ox + oy * oy;
		rippleAnim.radius = Math.sqrt(Math.max(dist(event.x, event.y), dist(event.x, height - event.y), dist(width - event.x, event.y), dist(width - event.x, height - event.y)));

		rippleAnim.restart();
	}

	SequentialAnimation {
		id: rippleAnim

		property real radius
		property real x
		property real y

		PropertyAction {
			property: "x"
			target: ripple
			value: rippleAnim.x
		}

		PropertyAction {
			property: "y"
			target: ripple
			value: rippleAnim.y
		}

		PropertyAction {
			property: "opacity"
			target: ripple
			value: 0.08
		}

		Anim {
			easing.bezierCurve: MaterialEasing.standardDecel
			from: 0
			properties: "implicitWidth,implicitHeight"
			target: ripple
			to: rippleAnim.radius * 2
		}

		Anim {
			property: "opacity"
			target: ripple
			to: 0
		}
	}

	CustomClippingRect {
		id: hoverLayer

		anchors.fill: parent
		border.pixelAligned: false
		color: Qt.alpha(root.color, root.disabled ? 0 : root.pressed ? 0.1 : root.containsMouse ? 0.08 : 0)
		radius: root.radius

		CustomRect {
			id: ripple

			border.pixelAligned: false
			color: root.color
			opacity: 0
			radius: 1000

			transform: Translate {
				x: -ripple.width / 2
				y: -ripple.height / 2
			}
		}
	}
}
