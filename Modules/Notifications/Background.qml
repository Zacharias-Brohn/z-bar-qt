import qs.Components
import qs.Config
import QtQuick
import QtQuick.Shapes

ShapePath {
	id: root

	readonly property bool flatten: wrapper.height < rounding * 2
	readonly property real rounding: 8
	readonly property real roundingY: flatten ? wrapper.height / 2 : rounding
	required property var sidebar
	required property Wrapper wrapper

	fillColor: DynamicColors.palette.m3surface
	strokeWidth: -1

	Behavior on fillColor {
		CAnim {
		}
	}

	PathLine {
		relativeX: -(root.wrapper.width + root.rounding)
		relativeY: 0
	}

	PathArc {
		radiusX: root.rounding
		radiusY: Math.min(root.rounding, root.wrapper.height)
		relativeX: root.rounding
		relativeY: root.roundingY
	}

	PathLine {
		relativeX: 0
		relativeY: root.wrapper.height - root.roundingY * 2
	}

	PathArc {
		direction: PathArc.Counterclockwise
		radiusX: root.sidebar.notifsRoundingX
		radiusY: Math.min(root.rounding, root.wrapper.height)
		relativeX: root.sidebar.notifsRoundingX
		relativeY: root.roundingY
	}

	PathLine {
		relativeX: root.wrapper.height > 0 ? root.wrapper.width - root.rounding - root.sidebar.notifsRoundingX : root.wrapper.width
		relativeY: 0
	}

	PathArc {
		radiusX: root.rounding
		radiusY: root.rounding
		relativeX: root.rounding
		relativeY: root.rounding
	}
}
