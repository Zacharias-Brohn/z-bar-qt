import Quickshell
import QtQuick
import Quickshell.Hyprland

FloatingWindow {
    id: root

    title: "terminal"
    minimumSize: Qt.size(400, 300)
    Component.onCompleted: {
        Hyprland.refreshToplevels()
        console.log(Hyprland.toplevels.values)
    }
}
