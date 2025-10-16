//@ pragma Env QT_STYLE_OVERRIDE=Breeze

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Caelestia
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

MouseArea {
    id: root

    required property SystemTrayItem item

    implicitWidth: 22
    implicitHeight: 22

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: event => {
        switch (event.button) {
            case Qt.LeftButton: root.item.activate(); break;
            case Qt.RightButton: 
            if (root.item.hasMenu) {
                menuAnchor.open();
            } 
            break;
        }
    }
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
        }
    }
    QsMenuAnchor {
        id: menuAnchor
        menu: root.item.menu
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.margins.top: 23
        anchor.adjustment: PopupAdjustment.SlideX
    }
}
