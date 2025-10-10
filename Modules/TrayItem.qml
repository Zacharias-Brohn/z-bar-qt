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
    implicitSize: 15
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            switch (event.button) {
                case Qt.LeftButton: root.item.activate(); break;
                case Qt.RightButton: 
                if (root.item.hasMenu) {
                    const window = QsWindow.window;
                    const widgetRect = window.contentItem.mapFromItem(root, -24, root.height -12 , root.width, root.height);
                    menuAnchor.anchor.rect = widgetRect;
                    menuAnchor.open();
                } 
                break;
            }
        }
    }
    QsMenuAnchor {
        id: menuAnchor
        menu: root.item.menu
        anchor.window: root.QsWindow.window?? null
        anchor.adjustment: PopupAdjustment.SlideX
    }
}
