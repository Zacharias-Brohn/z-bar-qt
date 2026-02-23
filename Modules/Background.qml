import QtQuick
import QtQuick.Shapes
import qs.Components
import qs.Config

ShapePath {
    id: root

    required property Wrapper wrapper
    required property bool invertBottomRounding
    readonly property real rounding: 8
    readonly property bool flatten: wrapper.height < rounding * 2
    readonly property real roundingY: flatten ? wrapper.height / 2 : rounding
    property real ibr: invertBottomRounding ? -1 : 1

    strokeWidth: -1
    fillColor: DynamicColors.palette.m3surface

    PathArc {
        relativeX: root.rounding
        relativeY: root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.wrapper.height)
    }

    PathLine {
        relativeX: 0
        relativeY: root.wrapper.height - root.roundingY - root.roundingY * root.ibr
    }

    PathArc {
        relativeX: root.rounding
        relativeY: root.roundingY * root.ibr
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.wrapper.height)
        direction: root.invertBottomRounding ? PathArc.Clockwise : PathArc.Counterclockwise
    }

    PathLine {
        relativeX: root.wrapper.width - root.rounding * 2
        relativeY: 0
    }

    PathArc {
        relativeX: root.rounding
        relativeY: -root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.wrapper.height)
        direction: PathArc.Counterclockwise
    }

    PathLine {
        relativeX: 0
        relativeY: -( root.wrapper.height - root.roundingY * 2 )
    }

    PathArc {
        relativeX: root.rounding
        relativeY: -root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.wrapper.height)
    }

    Behavior on fillColor {
        CAnim {}
    }
}
