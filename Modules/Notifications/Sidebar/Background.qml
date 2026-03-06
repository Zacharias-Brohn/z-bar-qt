import qs.Components
import qs.Config
import QtQuick
import QtQuick.Shapes

ShapePath {
	id: root

	readonly property bool flatten: wrapper.width < rounding * 2
	readonly property real notifsRoundingX: panels.notifications.height > 0 && notifsWidthDiff < rounding * 2 ? notifsWidthDiff / 2 : rounding
	readonly property real notifsWidthDiff: panels.notifications.width - wrapper.width
	required property var panels
	readonly property real rounding: 8
	readonly property real utilsRoundingX: utilsWidthDiff < rounding * 2 ? utilsWidthDiff / 2 : rounding
	readonly property real utilsWidthDiff: panels.utilities.width - wrapper.width
	required property Wrapper wrapper

	fillColor: flatten ? "transparent" : DynamicColors.palette.m3surface
	strokeWidth: -1

	Behavior on fillColor {
		CAnim {
		}
	}

	PathLine {
		relativeX: -root.wrapper.width - root.notifsRoundingX
		relativeY: 0
	}

	PathArc {
		radiusX: root.notifsRoundingX
		radiusY: root.rounding
		relativeX: root.notifsRoundingX
		relativeY: root.rounding
	}

	PathLine {
		relativeX: 0
		relativeY: root.wrapper.height - root.rounding * 2
	}

	PathArc {
		radiusX: root.utilsRoundingX
		radiusY: root.rounding
		relativeX: -root.utilsRoundingX
		relativeY: root.rounding
	}

	PathLine {
		relativeX: root.wrapper.width + root.utilsRoundingX
		relativeY: 0
	}
}
