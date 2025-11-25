import QtQuick
import QtQuick.Shapes
import qs.Modules as Modules

Shape {
    id: root

    required property Panels panels
    required property Item bar

    anchors.fill: parent
    anchors.margins: 8
    anchors.topMargin: bar.implicitHeight
    preferredRendererType: Shape.CurveRenderer

    Modules.Background {
        wrapper: root.panels.popouts

        startX: wrapper.x - rounding
        startY: wrapper.y
    }
}
