pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.DBusMenu
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import QtQml
import qs.Effects
import qs.Config
import qs.Modules

PanelWindow {
    id: root

    signal menuActionTriggered()
    signal finishedLoading()
    required property QsMenuHandle trayMenu
    required property point trayItemRect
    required property PanelWindow bar
    property var menuStack: []
    property real scaleValue: 0
    property alias focusGrab: grab.active
    property int entryHeight: 30
    property int biggestWidth: 0
    property int menuItemCount: menuOpener.children.values.length

    property color backgroundColor: DynamicColors.tPalette.m3surface
    property color highlightColor: DynamicColors.tPalette.m3primaryContainer
    property color textColor: DynamicColors.palette.m3onSurface
    property color disabledHighlightColor: DynamicColors.layer(DynamicColors.palette.m3primaryContainer, 0)
    property color disabledTextColor: DynamicColors.layer(DynamicColors.palette.m3onSurface, 0)

    QsMenuOpener {
        id: menuOpener
        menu: root.trayMenu
    }

    // onTrayMenuChanged: {
    //     listLayout.forceLayout();
    // }

    visible: false
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    mask: Region { id: mask; item: menuRect }

    function goBack() {
        if ( root.menuStack.length > 0 ) {
            menuChangeAnimation.start();
            root.biggestWidth = 0;
            root.trayMenu = root.menuStack.pop();
            listLayout.positionViewAtBeginning();
            backEntry.visible = false;
        }
    }

    function updateMask() {
        root.mask.changed();
    }

    onVisibleChanged: {
        if ( !visible )
            root.menuStack.pop();
            backEntry.visible = false;

        openAnim.start();
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        active: false
        onCleared: {
            closeAnim.start();
        }
    }

    SequentialAnimation {
        id: menuChangeAnimation
        ParallelAnimation {
            NumberAnimation {
                duration: MaterialEasing.standardTime / 2
                easing.bezierCurve: MaterialEasing.expressiveEffects
                from: 0
                property: "x"
                target: translateAnim
                to: -listLayout.width / 2
            }

            NumberAnimation {
                duration: MaterialEasing.standardTime / 2
                easing.bezierCurve: MaterialEasing.standard
                from: 1
                property: "opacity"
                target: columnLayout
                to: 0
            }
        }

        PropertyAction {
            property: "menu"
            target: columnLayout
        }

        ParallelAnimation {
            NumberAnimation {
                duration: MaterialEasing.standardTime / 2
                easing.bezierCurve: MaterialEasing.standard
                from: 0
                property: "opacity"
                target: columnLayout
                to: 1
            }

            NumberAnimation {
                duration: MaterialEasing.standardTime / 2
                easing.bezierCurve: MaterialEasing.expressiveEffects
                from: listLayout.width / 2
                property: "x"
                target: translateAnim
                to: 0
            }
        }
    }

    onMenuActionTriggered: {
        if ( root.menuStack.length > 0 ) {
            backEntry.visible = true;
        }
    }

    ParallelAnimation {
        id: closeAnim
        Anim {
            target: menuRect
            property: "implicitHeight"
            to: 0
            duration: MaterialEasing.expressiveEffectsTime
            easing.bezierCurve: MaterialEasing.expressiveEffects
        }
        Anim {
            targets: [ menuRect, shadowRect ]
            property: "opacity"
            from: 1
            to: 0
            duration: MaterialEasing.expressiveEffectsTime
            easing.bezierCurve: MaterialEasing.expressiveEffects
        }
        onFinished: {
            root.visible = false;
        }
    }

    ParallelAnimation {
        id: openAnim
        Anim {
            target: menuRect
            property: "implicitHeight"
            from: 0
            to: listLayout.contentHeight + ( root.menuStack.length > 0 ? root.entryHeight + 10 : 10 )
            duration: MaterialEasing.expressiveEffectsTime
            easing.bezierCurve: MaterialEasing.expressiveEffects
        }
        Anim {
            targets: [ menuRect, shadowRect ]
            property: "opacity"
            from: 0
            to: 1
            duration: MaterialEasing.expressiveEffectsTime
            easing.bezierCurve: MaterialEasing.expressiveEffects
        }
    }

    ShadowRect {
        id: shadowRect
        anchors.fill: menuRect
        radius: menuRect.radius
    }

    Rectangle {
        id: menuRect
        x: Math.round( root.trayItemRect.x - ( menuRect.implicitWidth / 2 ) + 11 )
        y: Math.round( root.trayItemRect.y - 5 )
        implicitWidth: listLayout.contentWidth + 10
        implicitHeight: listLayout.contentHeight + ( root.menuStack.length > 0 ? root.entryHeight + 10 : 10 )
        color: root.backgroundColor
        radius: 8
        clip: true

        Behavior on implicitWidth {
            NumberAnimation {
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            anchors.margins: 5
            spacing: 0
            transform: [
                Translate {
                    id: translateAnim
                    x: 0
                    y: 0
                }
            ]
            ListView {
                id: listLayout
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                spacing: 0
                contentWidth: root.biggestWidth
                contentHeight: contentItem.childrenRect.height
                model: menuOpener.children

                delegate: Rectangle {
                    id: menuItem
                    required property int index
                    required property QsMenuEntry modelData
                    property var child: QsMenuOpener {
                        menu: menuItem.modelData
                    }
                    property bool containsMouseAndEnabled: mouseArea.containsMouse && menuItem.modelData.enabled
                    property bool containsMouseAndNotEnabled: mouseArea.containsMouse && !menuItem.modelData.enabled
                    width: widthMetrics.width + (menuItem.modelData.icon ?? "" ? 30 : 0) + (menuItem.modelData.hasChildren ? 30 : 0) + 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: menuItem.modelData.isSeparator ? 1 : root.entryHeight
                    color: menuItem.modelData.isSeparator ? "#20FFFFFF" : containsMouseAndEnabled ? root.highlightColor : containsMouseAndNotEnabled ? root.disabledHighlightColor : "transparent"
                    radius: 4
                    visible: true

                    Behavior on color {
                        CAnim {
                            duration: 150
                        }
                    }

                    Component.onCompleted: {
                        var biggestWidth = root.biggestWidth;
                        var currentWidth = widthMetrics.width + (menuItem.modelData.icon ?? "" ? 30 : 0) + (menuItem.modelData.hasChildren ? 30 : 0) + 20;
                        if ( currentWidth > biggestWidth ) {
                            root.biggestWidth = currentWidth;
                        }
                    }

                    TextMetrics {
                        id: widthMetrics
                        text: menuItem.modelData.text
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        preventStealing: true
    propagateComposedEvents: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            if ( !menuItem.modelData.hasChildren ) {
                                if ( menuItem.modelData.enabled ) {
                                    menuItem.modelData.triggered();
                                    closeAnim.start();
                                }
                            } else {
                                root.menuStack.push(root.trayMenu);
                                menuChangeAnimation.start();
                                root.biggestWidth = 0;
                                root.trayMenu = menuItem.modelData;
                                listLayout.positionViewAtBeginning();
                                root.menuActionTriggered();
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        Text {
                            id: menuText
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.leftMargin: 10
                            text: menuItem.modelData.text
                            color: menuItem.modelData.enabled ? root.textColor : root.disabledTextColor
                        }
                        Image {
                            id: iconImage
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.rightMargin: 10
                            Layout.maximumWidth: 20
                            Layout.maximumHeight: 20
                            source: menuItem.modelData.icon
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: ColorOverlay {
                                color: menuItem.modelData.enabled ? "white" : "gray"
                            }
                        }
                        Text {
                            id: textArrow
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.rightMargin: 10
                            Layout.bottomMargin: 5
                            Layout.maximumWidth: 20
                            Layout.maximumHeight: 20
                            text: ""
                            color: menuItem.modelData.enabled ? "white" : "gray"
                            visible: menuItem.modelData.hasChildren ?? false
                        }
                    }
                }
            }
            Rectangle {
                id: backEntry
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: root.entryHeight
                color: mouseAreaBack.containsMouse ? "#15FFFFFF" : "transparent"
                radius: 4

                MouseArea {
                    id: mouseAreaBack
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.goBack();
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    verticalAlignment: Text.AlignVCenter
                    text: "Back "
                    color: "white"
                }
            }
        }
    }
}
