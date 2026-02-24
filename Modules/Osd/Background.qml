import QtQuick
import QtQuick.Shapes
import qs.Components
import qs.Config

ShapePath {
	id: root

	readonly property bool flatten: wrapper.width < rounding * 2
	readonly property real rounding: 10
	readonly property real roundingX: flatten ? wrapper.width / 2 : rounding
	required property Wrapper wrapper

	fillColor: DynamicColors.palette.m3surface
	strokeWidth: -1

	Behavior on fillColor {
		CAnim {
		}
	}

	PathArc {
		radiusX: Math.min(root.rounding, root.wrapper.width)
		radiusY: root.rounding
		relativeX: -root.roundingX
		relativeY: root.rounding
	}

	PathLine {
		relativeX: -(root.wrapper.width - root.roundingX * 3)
		relativeY: 0
	}

	PathArc {
		direction: PathArc.Counterclockwise
		radiusX: Math.min(root.rounding * 2, root.wrapper.width)
		radiusY: root.rounding * 2
		relativeX: -root.roundingX * 2
		relativeY: root.rounding * 2
	}

	PathLine {
		relativeX: 0
		relativeY: root.wrapper.height - root.rounding * 4
	}

	PathArc {
		direction: PathArc.Counterclockwise
		radiusX: Math.min(root.rounding * 2, root.wrapper.width)
		radiusY: root.rounding * 2
		relativeX: root.roundingX * 2
		relativeY: root.rounding * 2
	}

	PathLine {
		relativeX: root.wrapper.width - root.roundingX * 3
		relativeY: 0
	}

	PathArc {
		radiusX: Math.min(root.rounding, root.wrapper.width)
		radiusY: root.rounding
		relativeX: root.roundingX
		relativeY: root.rounding
	}
}
