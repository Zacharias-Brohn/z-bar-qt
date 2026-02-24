import QtQuick
import QtQuick.Shapes
import qs.Components
import qs.Config

ShapePath {
	id: root

	readonly property bool flatten: wrapper.height < rounding * 2
	property real ibr: invertBottomRounding ? -1 : 1
	required property bool invertBottomRounding
	readonly property real rounding: 8
	readonly property real roundingY: flatten ? wrapper.height / 2 : rounding
	required property Wrapper wrapper

	fillColor: DynamicColors.palette.m3surface
	strokeWidth: -1

	Behavior on fillColor {
		CAnim {
		}
	}

	PathArc {
		radiusX: root.rounding
		radiusY: Math.min(root.rounding, root.wrapper.height)
		relativeX: root.rounding
		relativeY: root.roundingY
	}

	PathLine {
		relativeX: 0
		relativeY: root.wrapper.height - root.roundingY - root.roundingY * root.ibr
	}

	PathArc {
		direction: root.invertBottomRounding ? PathArc.Clockwise : PathArc.Counterclockwise
		radiusX: root.rounding
		radiusY: Math.min(root.rounding, root.wrapper.height)
		relativeX: root.rounding
		relativeY: root.roundingY * root.ibr
	}

	PathLine {
		relativeX: root.wrapper.width - root.rounding * 2
		relativeY: 0
	}

	PathArc {
		direction: PathArc.Counterclockwise
		radiusX: root.rounding
		radiusY: Math.min(root.rounding, root.wrapper.height)
		relativeX: root.rounding
		relativeY: -root.roundingY
	}

	PathLine {
		relativeX: 0
		relativeY: -(root.wrapper.height - root.roundingY * 2)
	}

	PathArc {
		radiusX: root.rounding
		radiusY: Math.min(root.rounding, root.wrapper.height)
		relativeX: root.rounding
		relativeY: -root.roundingY
	}
}
