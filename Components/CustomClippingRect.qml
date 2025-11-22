import Quickshell.Widgets
import QtQuick
import qs.Modules

ClippingRectangle {
    id: root

    color: "transparent"

    Behavior on color {
        CAnim {}
    }
}
