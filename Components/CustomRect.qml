import QtQuick
import qs.Modules

Rectangle {
    id: root

    color: "transparent"

    Behavior on color {
        CAnim {}
    }
}
