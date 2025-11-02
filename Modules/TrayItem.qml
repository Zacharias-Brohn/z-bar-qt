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
    property var menuHandle

    implicitWidth: 22
    implicitHeight: 22

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    IconImage {
        id: icon

        anchors.fill: parent
        layer.enabled: true

        layer.onEnabledChanged: {
            if (layer.enabled && status === Image.Ready) 
                analyser.requestUpdate();
        }

        onStatusChanged: {
            if (layer.enabled && status === Image.Ready) 
                analyser.requestUpdate();
        }

        source: GetIcons.getTrayIcon(root.item.id, root.item.icon)

        mipmap: false
        asynchronous: true

        ImageAnalyser {
            id: analyser
            sourceItem: icon
            rescaleSize: 20
        }

        TrayMenu {
            id: trayMenu
            menu: root.item.menu
            anchor.item: root
            anchor.edges: Edges.Bottom
            onVisibleChanged: {
                if ( grab.active && !visible ) {
                    grab.active = false;
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [ trayMenu ]
                onCleared: {
                    trayMenu.visible = false;
                }
            }
        }
    }

    onClicked: {
        if ( mouse.button === Qt.LeftButton ) {
            root.item.activate();
        } else if ( mouse.button === Qt.RightButton ) {
            trayMenu.visible = !trayMenu.visible;
            grab.active = true;
        }
    }
}
