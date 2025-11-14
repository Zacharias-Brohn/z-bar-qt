//@ pragma Env QT_STYLE_OVERRIDE=Breeze

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Io
import qs.Modules

MouseArea {
    id: root

    required property SystemTrayItem item
    required property PanelWindow bar
    property point globalPos

    implicitWidth: 22
    implicitHeight: parent.height

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPositionChanged: {
        globalPos = root.mapToItem(root.bar.backgroundRect, 0, 0);
    }

    Image {
        id: icon

        Component.onCompleted: {
            console.log(root.item.icon);
        }

        property bool batteryHDPI: root.bar.screen.x < 0 && root.item.icon.includes("battery")
        property bool nmHDPI: root.bar.screen.x < 0 && root.item.icon.includes("nm-")

        anchors.centerIn: parent
        width: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
        height: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
        source: root.item.icon
        mipmap: true
        smooth: batteryHDPI ? false : ( nmHDPI ? false : true )
        asynchronous: true
        sourceSize.width: batteryHDPI ? 16 : ( nmHDPI ? 16 : 22 )
        sourceSize.height: batteryHDPI ? 16 : ( nmHDPI ? 16 : 22 )
        autoTransform: true
        fillMode: Image.PreserveAspectFit

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
            if ( root.item?.menu !== trayMenu.trayMenu ) {
                trayMenu.trayMenu = root.item?.menu;
            }
            trayMenu.visible = !trayMenu.visible;
            trayMenu.focusGrab = true;
        }
    }
}
