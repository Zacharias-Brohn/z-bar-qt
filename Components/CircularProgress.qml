import QtQuick
import QtQuick.Shapes
import qs.Config

Shape {
	id: root

	readonly property real arcRadius: (size - padding - strokeWidth) / 2
	property color bgColour: DynamicColors.palette.m3secondaryContainer
	property color fgColour: DynamicColors.palette.m3primary
	readonly property real gapAngle: ((spacing + strokeWidth) / (arcRadius || 1)) * (180 / Math.PI)
	property int padding: 0
	readonly property real size: Math.min(width, height)
	property int spacing: Appearance.spacing.small
	property int startAngle: -90
	property int strokeWidth: Appearance.padding.smaller
	readonly property real vValue: value || 1 / 360
	property real value

	asynchronous: true
	preferredRendererType: Shape.CurveRenderer

	ShapePath {
		capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
		fillColor: "transparent"
		strokeColor: root.bgColour
		strokeWidth: root.strokeWidth

		Behavior on strokeColor {
			CAnim {
				duration: Appearance.anim.durations.large
			}
		}

		PathAngleArc {
			centerX: root.size / 2
			centerY: root.size / 2
			radiusX: root.arcRadius
			radiusY: root.arcRadius
			startAngle: root.startAngle + 360 * root.vValue + root.gapAngle
			sweepAngle: Math.max(-root.gapAngle, 360 * (1 - root.vValue) - root.gapAngle * 2)
		}
	}

	ShapePath {
		capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
		fillColor: "transparent"
		strokeColor: root.fgColour
		strokeWidth: root.strokeWidth

		Behavior on strokeColor {
			CAnim {
				duration: Appearance.anim.durations.large
			}
		}

		PathAngleArc {
			centerX: root.size / 2
			centerY: root.size / 2
			radiusX: root.arcRadius
			radiusY: root.arcRadius
			startAngle: root.startAngle
			sweepAngle: 360 * root.vValue
		}
	}
}
