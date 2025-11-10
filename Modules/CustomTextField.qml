import Quickshell
import QtQuick
import QtQuick.Controls

TextField {
    id: root
    color: "white"
    horizontalAlignment: Text.AlignLeft
    echoMode: TextInput.Normal
    placeholderText: qsTr("Search applications...")
    background: null
    renderType: TextInput.NativeRendering

    font.family: "Rubik"

    cursorDelegate: Rectangle {
        id: cursor

        property bool disableBlink

        implicitWidth: 2
        color: "white"
        radius: 2

        Connections {
            target: root

            function onCursorPositionChanged(): void {
                if ( root.activeFocus && root.cursorVisible ) {
                    cursor.opacity = 1;
                    cursor.disableBlink = true;
                    enableBlink.restart();
                }
            }
        }

        Timer {
            id: enableBlink

            interval: 100
            onTriggered: cursor.disableBlink = false
        }

        Timer {
            running: root.activeFocus && root.cursorVisible && !cursor.disableBlink
            repeat: true
            triggeredOnStart: true
            interval: 500
            onTriggered: parent.opacity = parent.opacity === 1 ? 0 : 1
        }

        Binding {
            when: !root.activeFocus || !root.cursorVisible
            cursor.opacity: 0
        }

        Behavior on opacity {
            Anim {
                duration: 200
            }
        }
    }

    Keys.onPressed: {
        if ( event.key === Qt.Key_Down ) {
            appListView.decrementCurrentIndex();
            event.accepted = true;
        } else if ( event.key === Qt.Key_Up ) {
            appListView.incrementCurrentIndex();
            event.accepted = true;
        } else if ( event.key === Qt.Key_Return || event.key === Qt.Key_Enter ) {
            if ( appListView.currentItem ) {
                Search.launch(appListView.currentItem.modelData);
                launcherWindow.visible = false;
            }
            event.accepted = true;
        } else if ( event.key === Qt.Key_Escape ) {
            closeAnim.start();
            event.accepted = true;
        }
    }
}
