import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.Modules

IconImage {
    id: root
    required property SystemTrayItem item
    property var customMenu

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

                    root.customMenu = menuComponent.createObject(root);
                    root.customMenu.menuHandle = root.item.menu;

                    const window = QsWindow.window;
                    const widgetRect = window.contentItem.mapFromItem(root, 0, root.height + 4, root.width, root.height);
                    root.customMenu.anchor.rect = widgetRect
                    root.customMenu.anchor.window = window
                    root.customMenu.anchor.adjustment = PopupAdjustment.Flip
                    root.customMenu.visible = true;
                    root.customMenu.rebuild();
                    // menuAnchor.anchor.rect = widgetRect;
                    // menuAnchor.open();
                } 
                break;
            }
        }
    }
    
    Component {
        id: menuComponent
        CustomTrayMenu {}
    }

    // QsMenuAnchor {
    //     id: menuAnchor
    //     menu: root.item.menu
    //     anchor.window: root.QsWindow.window?? null
    //     anchor.adjustment: PopupAdjustment.Flip
    // }
}
