import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

Scope {
    id: root

    PanelWindow {
        id: launcherWindow
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: "transparent"
        visible: false

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        HyprlandFocusGrab {
            id: focusGrab
            windows: [ searchInput ]
        }

        onVisibleChanged: {
            if ( !visible ) {
                searchInput.text = "";
            }
        }

        GlobalShortcut {
            appid: "z-cast"
            name: "toggle-launcher"
            onPressed: {
                launcherWindow.visible = !launcherWindow.visible;
                focusGrab.active = true;
                searchInput.forceActiveFocus();
            }
        }

        mask: Region { item: backgroundRect }

        Rectangle {
            id: backgroundRect
            anchors.top: parent.top
            anchors.topMargin: 200
            implicitHeight: 800
            implicitWidth: 600
            x: Math.round(( parent.width - width ) / 2 )
            color: "#d01a1a1a"
            radius: 8
            border.color: "#444444"
            border.width: 1
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Layout.leftMargin: 5
                    color: "white"
                    horizontalAlignment: Text.AlignLeft
                    echoMode: TextInput.Normal
                    placeholderText: qsTr("Search applications...")
                    background: null

                    cursorDelegate: Rectangle {
                        id: cursor

                        property bool disableBlink

                        implicitWidth: 2
                        color: "white"
                        radius: 2

                        Connections {
                            target: searchInput

                            function onCursorPositionChanged(): void {
                                if ( searchInput.activeFocus && searchInput.cursorVisible ) {
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
                            running: searchInput.activeFocus && searchInput.cursorVisible && !cursor.disableBlink
                            repeat: true
                            triggeredOnStart: true
                            interval: 500
                            onTriggered: parent.opacity = parent.opacity === 1 ? 0 : 1
                        }

                        Binding {
                            when: !searchInput.activeFocus || !searchInput.cursorVisible
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
                            appListView.incrementCurrentIndex();
                            event.accepted = true;
                        } else if ( event.key === Qt.Key_Up ) {
                            appListView.decrementCurrentIndex();
                            event.accepted = true;
                        } else if ( event.key === Qt.Key_Return || event.key === Qt.Key_Enter ) {
                            if ( appListView.currentItem ) {
                                Search.launch(appListView.currentItem.modelData);
                                launcherWindow.visible = false;
                            }
                            event.accepted = true;
                        } else if ( event.key === Qt.Key_Escape ) {
                            launcherWindow.visible = false;
                            event.accepted = true;
                        }
                    }
                }

                Rectangle {
                    id: separator
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#444444"
                }

                Rectangle {
                    id: appListRect
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    clip: true
                    ListView {
                        id: appListView
                        anchors.fill: parent
                        model: ScriptModel {
                            id: appModel

                            onValuesChanged: {
                                appListView.currentIndex = 0;
                            }
                        }

                        preferredHighlightBegin: 0
                        preferredHighlightEnd: appListRect.height
                        highlightFollowsCurrentItem: false
                        highlightRangeMode: ListView.ApplyRange
                        focus: true
                        highlight: Rectangle {
                            radius: 4
                            color: "#FFFFFF"
                            opacity: 0.08

                            y: appListView.currentItem?.y
                            implicitWidth: appListView.width
                            implicitHeight: appListView.currentItem?.implicitHeight ?? 0

                            Behavior on y {
                                Anim {
                                    duration: MaterialEasing.expressiveDefaultSpatialTime
                                    easing.bezierCurve: MaterialEasing.expressiveFastSpatial
                                }
                            }
                        }

                        state: "apps"

                        states: [
                            State {
                                name: "apps"
                                PropertyChanges {
                                    appModel.values: Search.search(searchInput.text)
                                    appListView.delegate: appItem
                                }
                            }
                        ]

                        Component {
                            id: appItem
                            AppItem {
                            }
                        }

                        transitions: Transition {
                            SequentialAnimation {
                                ParallelAnimation {
                                    Anim {
                                        target: appListView
                                        property: "opacity"
                                        from: 1
                                        to: 0
                                        duration: 200
                                        easing.bezierCurve: MaterialEasing.standardAccel
                                    }
                                    Anim {
                                        target: appListView
                                        property: "scale"
                                        from: 1
                                        to: 0.9
                                        duration: 200
                                        easing.bezierCurve: MaterialEasing.standardAccel
                                    }
                                }
                                PropertyAction {
                                    targets: [model, appListView]
                                    properties: "values,delegate"
                                }
                                ParallelAnimation {
                                    Anim {
                                        target: appListView
                                        property: "opacity"
                                        from: 0
                                        to: 1
                                        duration: 200
                                        easing.bezierCurve: MaterialEasing.standardDecel
                                    }
                                    Anim {
                                        target: appListView
                                        property: "scale"
                                        from: 0.9
                                        to: 1
                                        duration: 200
                                        easing.bezierCurve: MaterialEasing.standardDecel
                                    }
                                }
                                PropertyAction {
                                    targets: [appListView.add, appListView.remove]
                                    property: "enabled"
                                    value: true
                                }
                            }
                        }

                        add: Transition {
                            enabled: !appListView.state
                            Anim {
                                properties: "opacity"
                                from: 0
                                to: 1
                            }

                            Anim {
                                properties: "scale"
                                from: 0.9
                                to: 1
                            }
                        }

                        remove: Transition {
                            enabled: !appListView.state
                            Anim {
                                properties: "opacity"
                                from: 1
                                to: 0
                            }

                            Anim {
                                properties: "scale"
                                from: 1
                                to: 0.9
                            }
                        }

                        move: Transition {
                            Anim {
                                property: "y"
                            }
                            Anim {
                                properties: "opacity,scale"
                                to: 1
                            }
                        }

                        addDisplaced: Transition {
                            Anim {
                                property: "y"
                                duration: 200
                            }
                            Anim {
                                properties: "opacity,scale"
                                to: 1
                            }
                        }

                        displaced: Transition {
                            Anim {
                                property: "y"
                            }
                            Anim {
                                properties: "opacity,scale"
                                to: 1
                            }
                        }
                    }
                }
            }
        }
    }
}
