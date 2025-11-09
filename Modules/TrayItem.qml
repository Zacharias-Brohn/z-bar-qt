//@ pragma Env QT_STYLE_OVERRIDE=Breeze

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.DBusMenu
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs.Modules

MouseArea {
    id: root

    required property SystemTrayItem item
    required property PanelWindow bar
    property point globalPos

    implicitWidth: 22
    implicitHeight: 22

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPositionChanged: {
        globalPos = root.mapToItem(root.bar.backgroundRect, 0, 0);
    }

    IconImage {
        id: icon

        anchors.centerIn: parent
        height: 22
        width: 22
        source: root.item.icon
        mipmap: true
        smooth: false
        asynchronous: true

        TrayMenu {
            id: trayMenu
            trayMenu: root.item?.menu
            trayItemRect: root.globalPos
            bar: root.bar
        }
    }

    Connections {
        target: trayMenu
        function onVisibleChanged() {
            if ( !trayMenu.visible ) {
                trayMenu.trayMenu = null;
            }
        }
    }

    onClicked: {
        if ( mouse.button === Qt.LeftButton ) {
            root.item.activate();
        } else if ( mouse.button === Qt.RightButton ) {
            trayMenu.visible = !trayMenu.visible;
            trayMenu.trayMenu = root.item?.menu;
            trayMenu.focusGrab = true;
        }
    }
}
