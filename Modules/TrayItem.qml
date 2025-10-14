//@ pragma Env QT_STYLE_OVERRIDE=Breeze

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

IconImage {
    id: root
    required property SystemTrayItem item

    source: root.item.icon
    implicitWidth: 18
    implicitHeight: 18
    mipmap: false
    asynchronous: true
    MouseArea {
        anchors.fill: parent
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
