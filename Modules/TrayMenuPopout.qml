pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

StackView {
    id: root

    required property Item popouts
    required property QsMenuHandle trayItem

    property int biggestWidth: 0

    implicitWidth: currentItem.implicitWidth
    implicitHeight: currentItem.implicitHeight

    initialItem: SubMenu {
        handle: root.trayItem
    }

    pushEnter: NoAnim {}
    pushExit: NoAnim {}
    popEnter: NoAnim {}
    popExit: NoAnim {}

    component NoAnim: Transition {
        NumberAnimation {
            duration: 0
        }
    }

    component SubMenu: Column {
        id: menu

        required property QsMenuHandle handle
        property bool isSubMenu
        property bool shown

        padding: 0
        spacing: 4

        opacity: shown ? 1 : 0
        scale: shown ? 1 : 0.8

        Component.onCompleted: shown = true
        StackView.onActivating: shown = true
        StackView.onDeactivating: shown = false
        StackView.onRemoved: destroy()

        Behavior on opacity {
            Anim {}
        }

        Behavior on scale {
            Anim {}
        }

        QsMenuOpener {
            id: menuOpener

            menu: menu.handle
        }

        Repeater {
            model: menuOpener.children

            CustomRect {
                id: item

                required property QsMenuEntry modelData

                implicitWidth: root.biggestWidth
                implicitHeight: modelData.isSeparator ? 1 : children.implicitHeight

                radius: 4
                color: modelData.isSeparator ? DynamicColors.palette.m3outlineVariant : "transparent"

                Loader {
                    id: children

                    anchors.left: parent.left
                    anchors.right: parent.right

                    active: !item.modelData.isSeparator
                    asynchronous: true

                    sourceComponent: Item {
                        implicitHeight: 30

                        StateLayer {
                            radius: item.radius
                            disabled: !item.modelData.enabled

                            function onClicked(): void {
                                const entry = item.modelData;
                                if (entry.hasChildren)
                                    root.push(subMenuComp.createObject(null, {
                                        handle: entry,
                                        isSubMenu: true
                                    }));
                                else {
                                    item.modelData.triggered();
                                    root.popouts.hasCurrent = false;
                                }
                            }
                        }

                        Loader {
                            id: icon

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 10

                            active: item.modelData.icon !== ""
                            asynchronous: true

                            sourceComponent: IconImage {
                                implicitSize: label.implicitHeight

                                source: item.modelData.icon
                            }
                        }

                        CustomText {
                            id: label

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 10

                            text: labelMetrics.elidedText
                            color: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
                        }

                        TextMetrics {
                            id: labelMetrics

                            text: item.modelData.text
                            font.pointSize: label.font.pointSize
                            font.family: label.font.family

                            Component.onCompleted: {
                                var biggestWidth = root.biggestWidth;
                                var currentWidth = labelMetrics.width + (item.modelData.icon ?? "" ? 30 : 0) + (item.modelData.hasChildren ? 30 : 0) + 20;
                                if ( currentWidth > biggestWidth ) {
                                    root.biggestWidth = currentWidth;
                                }
                            }
                        }

                        Loader {
                            id: expand

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right

                            active: item.modelData.hasChildren
                            asynchronous: true

                            sourceComponent: MaterialIcon {
                                text: "chevron_right"
                                color: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
                            }
                        }
                    }
                }
            }
        }

        Loader {
            active: menu.isSubMenu
            asynchronous: true

            sourceComponent: Item {
                implicitWidth: back.implicitWidth
                implicitHeight: back.implicitHeight + 2 / 2

                Item {
                    anchors.bottom: parent.bottom
                    implicitWidth: back.implicitWidth
                    implicitHeight: back.implicitHeight

                    CustomRect {
                        anchors.fill: parent
                        radius: 1000
                        color: DynamicColors.palette.m3secondaryContainer

                        StateLayer {
                            radius: parent.radius
                            color: DynamicColors.palette.m3onSecondaryContainer

                            function onClicked(): void {
                                root.pop();
                            }
                        }
                    }

                    Row {
                        id: back

                        anchors.verticalCenter: parent.verticalCenter

                        MaterialIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "chevron_left"
                            color: DynamicColors.palette.m3onSecondaryContainer
                        }

                        CustomText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Back")
                            color: DynamicColors.palette.m3onSecondaryContainer
                        }
                    }
                }
            }
        }
    }

    Component {
        id: subMenuComp

        SubMenu {}
    }
}
