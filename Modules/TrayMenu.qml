pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland

PopupWindow {
    id: root
    required property QsMenuHandle menu
    property int height: {
        let count = 0;
        for (let i = 0; i < repeater.count; i++) {
            if (!repeater.itemAt(i).modelData.isSeparator) count++;
        }
        return count * (entryHeight + 3);
    }
    property int entryHeight: 30
    property int maxWidth
    implicitWidth: maxWidth + 20
    implicitHeight: height
    color: "transparent"
    anchor.margins {
        left: -implicitWidth
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.menu
    }

    Rectangle {
        id: menuRect
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
                    property bool containsMouseAndEnabled: mouseArea.containsMouse && menuItem.modelData.enabled
                    property bool containsMouseAndNotEnabled: mouseArea.containsMouse && !menuItem.modelData.enabled
                    width: root.implicitWidth
                    Layout.maximumWidth: parent.width
                    Layout.fillHeight: true
                    height: root.entryHeight
                    color: modelData.isSeparator ? "transparent" : containsMouseAndEnabled ? "#15FFFFFF" : containsMouseAndNotEnabled ? "#08FFFFFF" : "transparent"
                    radius: 4
                    visible: modelData.isSeparator ? false : true
                    required property QsMenuEntry modelData

                    TextMetrics {
                        id: textMetrics
                        font: menuText.font
                        text: menuItem.modelData.text
                    }

                    Component.onCompleted: {
                        // Measure text width to determine maximumWidth
                        var textWidth = textMetrics.width + 20 + (iconImage.width > 0 ? iconImage.width + 10 : 0);
                        if ( textWidth > root.maxWidth ) {
                            root.maxWidth = textWidth
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
                            if ( !menuItem.modelData.hasChildren ) {
                                if ( menuItem.modelData.enabled ) {
                                    menuItem.modelData.triggered();
                                    root.visible = false;
                                }
                            } else {
                                subMenuComponent.createObject( null, {
                                    menu: menuItem.modelData,
                                    anchor: {
                                        item: menuItem,
                                        edges: Edges.Right
                                    },
                                    visible: true
                                })
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
                    }
                }
            }
        }
    }
    Component {
        id: subMenuComponent
        SubMenu {}
    }
}
