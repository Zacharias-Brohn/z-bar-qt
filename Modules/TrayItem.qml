//@ pragma Env QT_STYLE_OVERRIDE=Breeze

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Caelestia
import Quickshell
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

        ImageAnalyser {
            id: analyser
            sourceItem: icon
            rescaleSize: 22
        }

        TrayMenu {
            id: trayMenu
            menu: menuOpener
            trayItemRect: root.globalPos
            bar: root.bar
        }
    }

    onClicked: {
        if ( mouse.button === Qt.LeftButton ) {
            root.item.activate();
        } else if ( mouse.button === Qt.RightButton ) {
            if ( trayMenu.menu != menuOpener ) {
                trayMenu.menu = menuOpener;
            }
            trayMenu.visible = !trayMenu.visible;
            console.log(root.x);
        }
    }

    QsMenuOpener {
        id: menuOpener

        menu: root.item?.menu
    }
}
