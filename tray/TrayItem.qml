pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root

    required property int index
    property var menu: TrayItemMenu {
        height: trayMenu.children.values.length * 30
        trayMenu: trayMenu
        width: 500
    }
    required property SystemTrayItem modelData

    implicitHeight: trayItemIcon.width
    implicitWidth: this.implicitHeight

    Image {
        id: trayItemIcon

        anchors.centerIn: parent
        antialiasing: true
        height: this.width
        mipmap: true
        smooth: true
        source: {
            // adapted from soramanew
            const icon = root.modelData?.icon;
            if (icon.includes("?path=")) {
                const [name, path] = icon.split("?path=");
                return `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
            }
            return root.modelData.icon;
        }
        width: 18

        // too blurry for now
        // layer.enabled: true
        // layer.effect: MultiEffect {
        //   colorizationColor: Dat.Colors.current.secondary
        //   colorization: 1.0
        //   antialiasing: true
        //   smooth: true
        // }

        MouseArea {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent

            onClicked: mevent => {
                if (mevent.button == Qt.LeftButton) {
                    root.modelData.activate();
                    return;
                }

                if (!root.modelData.hasMenu) {
                    return;
                } else {
                    root.menu.visible = true;
                }
            }
        }
    }

    QsMenuOpener {
        id: trayMenu

        menu: root.modelData?.menu
    }
}
