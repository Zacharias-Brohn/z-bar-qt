pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland

PopupWindow {
    id: root

    signal menuActionTriggered()
    required property QsMenuOpener menu
    property var menuStack: []

    function calcHeight() {
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
            count++;
        }
        return (count * entryHeight) + ((count - 1) * 2) + (separatorCount * 3) + 10;
    }

    function calcWidth() {
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

    function goBack() {
        if ( root.menuStack.length > 0 ) {
            root.menu = root.menuStack.pop();
        }
    }

    onVisibleChanged: {
        if ( visible ) {
            root.menuStack = [];
        }
    }

    TextMetrics {
        id: tempMetrics
        text: ""
    }

    property int height: calcHeight()
    property int entryHeight: 30
    property int maxWidth: calcWidth()
    implicitWidth: maxWidth + 20
    implicitHeight: height
    color: "transparent"
    anchor.gravity: Edges.Bottom

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

    Rectangle {
        id: menuRect
        anchors.fill: parent
        color: "#80151515"
        radius: 8
        border.color: "#40FFFFFF"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 0
            ListView {
                id: listLayout
                Layout.fillWidth: true
                Layout.preferredHeight: root.calcHeight() - ( root.menuStack.length > 0 ? root.entryHeight + 10 : 0 )
                spacing: 2
                model: ScriptModel {
                    values: [...root.menu?.children.values]
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
                visible: true
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
