import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    required property PanelWindow bar
    implicitHeight: parent.height
    implicitWidth: rowL.implicitWidth + 20
    color: "transparent"

    RowLayout {
        spacing: 10
        id: rowL
        anchors.centerIn: parent
        Repeater {
            model: SystemTray.items
            TrayItem {
                required property SystemTrayItem modelData
                item: modelData
            }
        }
    }
}
