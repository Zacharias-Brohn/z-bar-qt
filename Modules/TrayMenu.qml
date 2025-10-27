pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

PopupWindow {
    id: root
    required property QsMenuHandle menu
    property int height: entryCount * ( entryHeight + 3 )
    property int entryHeight: 30
    property int entryCount: 0
    implicitWidth: 300
    implicitHeight: height
    color: "transparent"

    QsMenuOpener {
        id: menuOpener
        menu: root.menu
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onCleared: {
            root.visible = false;
        }
    }

    onVisibleChanged: {
        grab.active = root.visible;
    }
    Rectangle {
        anchors.fill: parent
        color: "#90000000"
        radius: 8
        border.color: "#10FFFFFF"
        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            anchors.margins: 5
            spacing: 2
            Repeater {
                id: repeater
                model: menuOpener.children
                Rectangle {
                    id: menuItem
                    width: root.implicitWidth
                    Layout.maximumWidth: parent.width
                    Layout.fillHeight: true
                    height: root.entryHeight
                    color: mouseArea.containsMouse && !modelData.isSeparator ? "#15FFFFFF" : "transparent"
                    radius: 4
                    visible: modelData.isSeparator ? false : true
                    required property QsMenuEntry modelData

                    Component.onCompleted: {
                        if ( !modelData.isSeparator ) {
                            root.entryCount += 1;
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        preventStealing: true
                        propagateComposedEvents: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            menuItem.modelData.triggered();
                            root.visible = false;
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: menuItem.modelData.text
                        color: "white"
                    }
                }
            }
        }
    }
}
