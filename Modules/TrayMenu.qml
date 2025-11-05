pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland

PanelWindow {
    id: root

    signal menuActionTriggered()
    required property QsMenuOpener menu
    required property point trayItemRect
    required property PanelWindow bar
    property var menuStack: []
    property real scaleValue: 0

    property int height: calcSize("h")
    property int entryHeight: 30
    property int maxWidth: calcSize("w")

    visible: false
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    function calcSize(String) {
        if ( String === "w" ) {
            let menuWidth = 0;
            for ( let i = 0; i < listLayout.count; i++ ) {
                if ( !listLayout.model.values[i].isSeparator ) {
                    let entry = listLayout.model.values[i];
                    tempMetrics.text = entry.text;
                    let textWidth = tempMetrics.width + 20 + (entry.icon ?? "" ? 30 : 0) + (entry.hasChildren ? 30 : 0);
                    if ( textWidth > menuWidth ) {
                        menuWidth = textWidth;
                    }
                }
            }
            return menuWidth;
        }
        if ( String === "h" ) {
            let count = 0;
            let separatorCount = 0;
            for (let i = 0; i < listLayout.count; i++) {
                if (!listLayout.model.values[i].isSeparator) {
                    count++;
                } else {
                    separatorCount++;
                }
            }
            if ( root.menuStack.length > 0 ) {
                backEntry.visible = true;
                count++;
            }
            return (count * entryHeight) + ((count - 1) * 2) + (separatorCount * 3) + 10;
        }
    }

    function goBack() {
        if ( root.menuStack.length > 0 ) {
            root.menu = root.menuStack.pop();
            backEntry.visible = false;
        }
    }

    onVisibleChanged: {
        if ( !visible ) {
            goBack();
        } else {
            scaleValue = 0;
            scaleAnimation.start();
        }
    }

    TextMetrics {
        id: tempMetrics
        text: ""
    }


    NumberAnimation {
        id: scaleAnimation
        target: root
        property: "scaleValue"
        from: 0
        to: 1
        duration: 150
        easing.type: Easing.OutCubic
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            root.visible = false;
        }
    }

    Behavior on menu {
        SequentialAnimation {
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
    }

    Rectangle {
        id: menuRect
        x: root.trayItemRect.x - ( menuRect.implicitWidth / 2 ) + 11
        y: root.trayItemRect.y - 5
        implicitHeight: root.height
        implicitWidth: root.maxWidth + 20
        color: "#80151515"
        radius: 8
        border.color: "#40FFFFFF"
        clip: true

        Behavior on implicitHeight {
            NumberAnimation {
                duration: MaterialEasing.standardTime
                easing.bezierCurve: MaterialEasing.standard
            }
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: MaterialEasing.standardTime
                easing.bezierCurve: MaterialEasing.standard
            }
        }

        transform: [
            Scale {
                origin.x: menuRect.width / 2
                origin.y: 0
                xScale: root.scaleValue
                yScale: root.scaleValue
            }
        ]


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
                Layout.preferredHeight: root.height - ( root.menuStack.length > 0 ? root.entryHeight + 10 : 0 )
                spacing: 2
                model: ScriptModel {
                    values: [...root.menu?.children.values]
                }

                add: Transition {
                    NumberAnimation {
                        property: "x"
                        from: listLayout.width
                        to: 0
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                move: Transition {
                    NumberAnimation {
                        property: "x"
                        from: 0
                        to: -listLayout.width
                        duration: 200
                        easing.type: Easing.InCubic
                    }
                }

                delegate: Rectangle {
                    id: menuItem
                    required property QsMenuEntry modelData
                    property var child: QsMenuOpener {
                        menu: menuItem.modelData
                    }
                    property bool containsMouseAndEnabled: mouseArea.containsMouse && menuItem.modelData.enabled
                    property bool containsMouseAndNotEnabled: mouseArea.containsMouse && !menuItem.modelData.enabled
                    width: root.implicitWidth
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: menuItem.modelData.isSeparator ? 1 : root.entryHeight
                    color: menuItem.modelData.isSeparator ? "#20FFFFFF" : containsMouseAndEnabled ? "#15FFFFFF" : containsMouseAndNotEnabled ? "#08FFFFFF" : "transparent"
                    radius: 4
                    visible: true

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
                                    root.menuActionTriggered();
                                    root.visible = false;
                                }
                            } else {
                                root.menuStack.push(root.menu);
                                root.menu = menuItem.child;
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
                            color: menuItem.modelData.enabled ? "white" : "gray"
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
