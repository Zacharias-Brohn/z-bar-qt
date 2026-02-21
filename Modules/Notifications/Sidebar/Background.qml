import qs.Components
import qs.Config
import qs.Modules as Modules
import QtQuick
import QtQuick.Shapes

ShapePath {
    id: root

    required property Wrapper wrapper
    required property var panels

    readonly property real rounding: 8

    readonly property real notifsWidthDiff: panels.notifications.width - wrapper.width
    readonly property real notifsRoundingX: panels.notifications.height > 0 && notifsWidthDiff < rounding * 2 ? notifsWidthDiff / 2 : rounding

    readonly property real utilsWidthDiff: panels.utilities.width - wrapper.width
    readonly property real utilsRoundingX: utilsWidthDiff < rounding * 2 ? utilsWidthDiff / 2 : rounding

	readonly property bool flatten: wrapper.width < rounding * 2

    strokeWidth: -1
	fillColor: flatten ? "transparent" : DynamicColors.palette.m3surface

    PathLine {
        relativeX: -root.wrapper.width - root.notifsRoundingX
        relativeY: 0
    }
    PathArc {
        relativeX: root.notifsRoundingX
        relativeY: root.rounding
        radiusX: root.notifsRoundingX
        radiusY: root.rounding
    }
    PathLine {
        relativeX: 0
        relativeY: root.wrapper.height - root.rounding * 2
    }
    PathArc {
        relativeX: -root.utilsRoundingX
        relativeY: root.rounding
        radiusX: root.utilsRoundingX
        radiusY: root.rounding
    }
    PathLine {
        relativeX: root.wrapper.width + root.utilsRoundingX
        relativeY: 0
    }

    Behavior on fillColor {
        Modules.CAnim {}
    }
}
