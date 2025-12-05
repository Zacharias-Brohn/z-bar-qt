import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import qs.Config
import qs.Helpers
import qs.Effects
import qs.Paths

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

		WlrLayershell.namespace: "ZShell-Launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: {
            if ( !visible ) {
                searchInput.text = "";
                appListLoader.item.currentIndex = 0;
                appListLoader.item.positionViewAtBeginning();
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
                    }
                }
                searchInput.forceActiveFocus();
            }
        }

        ShadowRect {
            id: effects
            anchors {
                top: appListRect.top
                bottom: backgroundRect.bottom
                left: appListRect.left
                right: appListRect.right
            }
            radius: 8
        }

        Rectangle {
            id: backgroundRect

            property color backgroundColor: Config.useDynamicColors ? DynamicColors.tPalette.m3surface : Config.baseBgColor

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Config.useDynamicColors ? 0 : -1
            implicitHeight: mainLayout.childrenRect.height + 20
            implicitWidth: appListRect.implicitWidth
            x: Math.round(( parent.width - width ) / 2 )
            color: backgroundColor
            opacity: 1
            border.width: Config.useDynamicColors ? 0 : 1
            border.color: Config.useDynamicColors ? "transparent" : Config.baseBorderColor

            ParallelAnimation {
                id: openAnim
                Anim {
                    target: appListRect
                    duration: MaterialEasing.expressiveDefaultSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                    property: "implicitHeight"
                    from: 40
                    to: appListContainer.implicitHeight + 20
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
                    duration: MaterialEasing.expressiveDefaultSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                    property: "implicitHeight"
                    from: appListContainer.implicitHeight
                    to: 0
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
            implicitWidth: appListContainer.implicitWidth + 20
            implicitHeight: appListContainer.implicitHeight + 20
            anchors.bottom: backgroundRect.top
            anchors.bottomMargin: Config.useDynamicColors ? 0 : -1
            color: backgroundRect.color
            topRightRadius: 8
            topLeftRadius: 8
            border.color: Config.useDynamicColors ? "transparent" : backgroundRect.border.color
            clip: true

            Behavior on implicitHeight {
                Anim {
                    duration: MaterialEasing.expressiveFastSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                }
            }

            Behavior on implicitWidth {
                Anim {
                    duration: MaterialEasing.expressiveFastSpatialTime
                    easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                }
            }

            Item {
                anchors.centerIn: parent
                id: appListContainer
                visible: true
                clip: true
                property var showWallpapers: searchInput.text.startsWith(">")
                state: showWallpapers ? "wallpaperpicker" : "apps"
                states: [
                    State {
                        name: "apps"
                        PropertyChanges {
                            appListLoader.active: true
                            appListContainer.implicitHeight: appListLoader.implicitHeight
                            appListContainer.implicitWidth: 600
                        }
                    },
                    State {
                        name: "wallpaperpicker"
                        PropertyChanges {
                            wallpaperPickerLoader.active: true
                            appListContainer.implicitHeight: wallpaperPickerLoader.implicitHeight 
                            appListContainer.implicitWidth: wallpaperPickerLoader.implicitWidth
                        }
                    }
                ]
                Loader {
                    id: wallpaperPickerLoader
                    active: false
                    anchors.fill: parent
                    sourceComponent: PathView {
                        id: wallpaperPickerView
                        anchors.fill: parent
                        model: ScriptModel {
                            id: wallpaperModel
                            readonly property string search: searchInput.text.split(" ").slice(1).join(" ")

                            values: SearchWallpapers.query( search )
                            onValuesChanged: wallpaperPickerView.currentIndex = SearchWallpapers.list.findIndex( w => w.path === WallpaperPath.currentWallpaperPath )
                        }

                        readonly property int itemWidth: 288 + 10
                        readonly property int numItems: {
                            const screen = QsWindow.window?.screen;
                            if (!screen)
                                return 0;

                            // Screen width - 4x outer rounding - 2x max side thickness (cause centered)
                            const margins = 10;
                            const maxWidth = screen.width - margins * 2;

                            if ( maxWidth <= 0 )
                                return 0;


                            const maxItemsOnScreen = Math.floor( maxWidth / itemWidth );
                            const visible = Math.min( maxItemsOnScreen, Config.maxWallpapers, wallpaperModel.values.length );

                            if ( visible === 2 )
                                return 1;
                            if ( visible > 1 && visible % 2 === 0 )
                                return visible - 1;
                            return visible;
                        }

                        Component.onCompleted: currentIndex = SearchWallpapers.list.findIndex( w => w.path === WallpaperPath.currentWallpaperPath )
                        Component.onDestruction: SearchWallpapers.stopPreview()

                        onCurrentItemChanged: {
                            if ( currentItem )
                                SearchWallpapers.preview( currentItem.modelData.path );
                                Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/SchemeColorGen.py"), `--path=${currentItem.modelData.path}`, `--thumbnail=${Paths.cache}/imagecache/thumbnail.jpg`, `--output=${Paths.state}/scheme.json`]);
                        }

                        cacheItemCount: 5
                        snapMode: PathView.SnapToItem
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        highlightRangeMode: PathView.StrictlyEnforceRange

                        pathItemCount: numItems
                        implicitHeight: 212
                        implicitWidth: Math.min( numItems, count ) * itemWidth

                        path: Path {
                            startY: wallpaperPickerView.height / 2

                            PathAttribute {
                                name: "z"
                                value: 0
                            }
                            PathLine {
                                x: wallpaperPickerView.width / 2
                                relativeY: 0
                            }
                            PathAttribute {
                                name: "z"
                                value: 1
                            }
                            PathLine {
                                x: wallpaperPickerView.width
                                relativeY: 0
                            }
                        }

                        focus: true

                        delegate: WallpaperItem { }
                    }
                }
                Loader {
                    id: appListLoader
                    active: false
                    anchors.fill: parent
                    sourceComponent: ListView {
                        id: appListView

                        property color highlightColor: Config.useDynamicColors ? DynamicColors.tPalette.m3onSurface : "#FFFFFF"

                        anchors.fill: parent
                        model: ScriptModel {
                            id: appModel

                            onValuesChanged: {
                                appListView.currentIndex = 0;
                            }
                        }

                        verticalLayoutDirection: ListView.BottomToTop
                        implicitHeight: Math.min( count, Config.appCount ) * 48

                        preferredHighlightBegin: 0
                        preferredHighlightEnd: appListView.height
                        highlightFollowsCurrentItem: false
                        highlightRangeMode: ListView.ApplyRange
                        focus: true
                        highlight: Rectangle {
                            radius: 4
                            color: appListView.highlightColor
                            opacity: Config.useDynamicColors ? 0.20 : 0.08

                            y: appListView.currentItem?.y
                            implicitWidth: appListView.width
                            implicitHeight: appListView.currentItem?.implicitHeight ?? 0

                            Behavior on y {
                                Anim {
                                    duration: MaterialEasing.expressiveEffectsTime
                                    easing.bezierCurve: MaterialEasing.expressiveEffects
                                }
                            }
                        }

                        property list<var> search: Search.search( searchInput.text )

                        state: {
                            const text = searchInput.text
                            if ( search.length === 0 ) {
                                return "noresults"
                            } else {
                                return "apps"
                            }
                        }

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

                        Component {
                            id: wallpaperItem
                            WallpaperItem { }
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
}
