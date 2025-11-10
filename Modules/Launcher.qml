import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
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

        onVisibleChanged: {
            if ( !visible ) {
                searchInput.text = "";
            }
        }

        GlobalShortcut {
            appid: "z-cast"
            name: "toggle-launcher"
            onPressed: {
                if ( !launcherWindow.visible ) {
                    if ( !openAnim.running ) {
                        openAnim.start();
                    }
                } else if ( launcherWindow.visible ) {
                    if ( !closeAnim.running ) {
                        closeAnim.start();
                    } else if ( openAnim.running ) {
                        openAnim.stop();
                        closeAnim.start();
                    } else if ( closeAnim.running ) {
                        closeAnim.stop();
                        openAnim.start();
                    }
                }
                searchInput.forceActiveFocus();
            }
        }

        // mask: Region { item: backgroundRect }

        Rectangle {
            id: shadowRect
            anchors {
                top: appListView.count > 0 ? appListRect.top : backgroundRect.top
                bottom: backgroundRect.bottom
                left: appListRect.left
                right: appListRect.right
            }
            layer.enabled: true
            radius: 8
            color: "black"
            visible: false
        }

        MultiEffect {
            id: effects
            source: shadowRect
            anchors.fill: shadowRect
            shadowBlur: 2.0
            shadowEnabled: true
            shadowOpacity: 1
            shadowColor: "black"
            maskSource: shadowRect
            maskEnabled: true
            maskInverted: true
            autoPaddingEnabled: true
        }

        Rectangle {
            id: backgroundRect
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -1
            implicitHeight: mainLayout.childrenRect.height + 20
            implicitWidth: 600
            x: Math.round(( parent.width - width ) / 2 )
            color: "#d01a1a1a"
            opacity: 1
            border.color: "#444444"
            border.width: 1

            ParallelAnimation {
                id: openAnim
                Anim {
                    target: appListRect
                    duration: MaterialEasing.expressiveFastSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                    property: "implicitHeight"
                    from: 40
                    to: appListView.implicitHeight + 20
                }
                Anim {
                    target: appListRect
                    duration: 50
                    property: "opacity"
                    from: 0
                    to: 1
                }
                Anim {
                    target: backgroundRect
                    duration: 50
                    property: "opacity"
                    from: 0
                    to: 1
                }
                Anim {
                    target: effects
                    duration: 50
                    property: "opacity"
                    from: 0
                    to: 1
                }
                onStarted: {
                    launcherWindow.visible = true;
                }
            }

            ParallelAnimation {
                id: closeAnim
                Anim {
                    target: appListRect
                    duration: MaterialEasing.expressiveFastSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                    property: "implicitHeight"
                    from: appListView.implicitHeight
                    to: 40
                }
                SequentialAnimation {
                    PauseAnimation { duration: 120 }

                    ParallelAnimation {
                        Anim {
                            target: backgroundRect
                            duration: 50
                            property: "opacity"
                            from: 1
                            to: 0
                        }
                        Anim {
                            target: appListRect
                            duration: 50
                            property: "opacity"
                            from: 1
                            to: 0
                        }
                        Anim {
                            target: effects
                            duration: 50
                            property: "opacity"
                            from: 1
                            to: 0
                        }
                    }
                }
                onStopped: {
                    launcherWindow.visible = false;
                }
            }

            Column {
                id: mainLayout
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                clip: true

                CustomTextField {
                    id: searchInput
                    implicitHeight: 30
                    implicitWidth: parent.width
                }
            }
        }

        Rectangle {
            id: appListRect
            x: Math.round(( parent.width - width ) / 2 )
            implicitWidth: backgroundRect.implicitWidth
            implicitHeight: appListView.implicitHeight + 20
            anchors.bottom: backgroundRect.top
            anchors.bottomMargin: -1
            color: backgroundRect.color
            topRightRadius: 8
            topLeftRadius: 8
            border.color: backgroundRect.border.color

            Behavior on implicitHeight {
                Anim {
                    duration: MaterialEasing.expressiveFastSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                }
            }

            Item {
                anchors.fill: parent
                anchors.margins: 10
                visible: appListView.count > 0
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

                    verticalLayoutDirection: ListView.BottomToTop
                    implicitHeight: Math.min( count, 20 ) * 48

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

                    property list<var> search: Search.search( searchInput.text )

                    state: search.length === 0 ? "noresults" : "apps"

                    states: [
                        State {
                            name: "apps"
                            PropertyChanges {
                                appModel.values: Search.search(searchInput.text)
                                appListView.delegate: appItem
                            }
                        },
                        State {
                            name: "noresults"
                            PropertyChanges {
                                appModel.values: [1]
                                appListView.delegate: noResultsItem
                            }
                        }
                    ]

                    Component {
                        id: appItem
                        AppItem {
                        }
                    }

                    Component {
                        id: noResultsItem
                        Item {
                            width: appListView.width
                            height: 48
                            Text {
                                id: icon
                                anchors.verticalCenter: parent.verticalCenter
                                property real fill: 0
                                text: "\ue000"
                                color: "#cccccc"
                                renderType: Text.NativeRendering
                                font.pointSize: 28
                                font.family: "Material Symbols Outlined"
                                font.variableAxes: ({
                                    FILL: fill.toFixed(1),
                                    GRAD: -25,
                                    opsz: fontInfo.pixelSize,
                                    wght: fontInfo.weight
                                })
                            }

                            Text {
                                anchors.left: icon.right
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: "No results found"
                                color: "#cccccc"
                                renderType: Text.NativeRendering
                                
                                font.pointSize: 12
                                font.family: "Rubik"
                            }
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
                            from: 0.95
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
                            to: 0.95
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
