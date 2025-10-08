pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Modules

PopupWindow {
    id: root
    property QsMenuHandle menu
    property var anchorItem: null
    property real anchorX
    property real anchorY
    property bool isSubMenu: false
    property bool isHovered: rootMouseArea.containsMouse
    property ShellScreen screen

    readonly property int menuWidth: 250

    implicitWidth: menuWidth

    // Use the content height of the Flickable for implicit height
    implicitHeight: Math.min(screen ? screen.height * 0.9 : Screen.height * 0.9, flickable.contentHeight)
    visible: false
    color: "transparent"
    anchor.item: anchorItem
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY - (isSubMenu ? 0 : 4)

    function showAt(item, x, y) {
        if (!opener.children || opener.children.values.length === 0) {
            //Logger.warn("TrayMenu", "Menu not ready, delaying show")
            Qt.callLater(() => showAt(item, x, y))
            return
        }

        anchorItem = item
        anchorX = x
        anchorY = y

        visible = true
        forceActiveFocus()

        // Force update after showing.
        Qt.callLater(() => {
            root.anchor.updateAnchor()
        })
    }

    function hideMenu() {
        visible = false

        // Clean up all submenus recursively
        for (var i = 0; i < columnLayout.children.length; i++) {
            const child = columnLayout.children[i]
            if (child?.subMenu) {
                child.subMenu.hideMenu()
                child.subMenu.destroy()
                child.subMenu = null
            }
        }
    }

    // Full-sized, transparent MouseArea to track the mouse.
    MouseArea {
        id: rootMouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Item {
        anchors.fill: parent
        Keys.onEscapePressed: root.hideMenu()
    }

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Rectangle {
        anchors.fill: parent
        color: "#ee202020"
        border.color: "#555555"
        border.width: 1
        radius: 6
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 4
        contentHeight: columnLayout.implicitHeight
        interactive: true

        // Use a ColumnLayout to handle menu item arrangement
        ColumnLayout {
            id: columnLayout
            width: flickable.width
            spacing: 2

            Repeater {
                model: opener.children ? [...opener.children.values] : []

                delegate: Rectangle {
                    id: entry
                    required property var modelData

                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: {
                        if (modelData?.isSeparator) {
                            return 8
                        } else {
                            // Calculate based on text content
                            const textHeight = text.contentHeight
                            return Math.max(24)
                        }
                    }

                    color: "transparent"
                    property var subMenu: null

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        visible: modelData?.isSeparator ?? false
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: "transparent"
                            }
                            GradientStop {
                                position: 0.1
                                color: "red"
                            }
                            GradientStop {
                                position: 0.9
                                color: "blue"
                            }
                            GradientStop {
                                position: 1.0
                                color: "transparent"
                            }
                        }
                    }

                    Rectangle {
                        id: backgroundRect
                        anchors.fill: parent
                        color: "transparent"
                        radius: 4
                        visible: !(modelData?.isSeparator ?? false)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 2
                            spacing: 4

                            Text {
                                id: text
                                Layout.fillWidth: true
                                color: "white"
                                text: modelData?.text !== "" ? modelData?.text.replace(/[\n\r]+/g, ' ') : "..."
                                font.pointSize: 12
                                verticalAlignment: Text.AlignVCenter
                            }

                            Image {
                                Layout.preferredWidth: 4
                                Layout.preferredHeight: 4
                                source: modelData?.icon ?? ""
                                visible: (modelData?.icon ?? "") !== ""
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && root.visible

                            onClicked: {
                                if (modelData && !modelData.isSeparator && !modelData.hasChildren) {
                                    modelData.triggered()
                                    root.hideMenu()
                                }
                            }

                            onEntered: {
                                if (!root.visible)
                                return
                                console.log(root.screen.name)
                                backgroundRect.color = "#30ffffff"

                                // Close all sibling submenus
                                for (var i = 0; i < columnLayout.children.length; i++) {
                                    const sibling = columnLayout.children[i]
                                    if (sibling !== entry && sibling?.subMenu) {
                                        sibling.subMenu.hideMenu()
                                        sibling.subMenu.destroy()
                                        sibling.subMenu = null
                                    }
                                }

                                // Create submenu if needed
                                if (modelData?.hasChildren) {
                                    if (entry.subMenu) {
                                        entry.subMenu.hideMenu()
                                        entry.subMenu.destroy()
                                    }

                                    // Need a slight overlap so that menu don't close when moving the mouse to a submenu
                                    const submenuWidth = menuWidth // Assuming a similar width as the parent
                                    const overlap = 4 // A small overlap to bridge the mouse path

                                    // Determine submenu opening direction based on bar position and available space
                                    let openLeft = false

                                    // Check bar position first
                                    const barPosition = "top"
                                    const globalPos = entry.mapToItem(null, 0, 0)

                                    if (barPosition === "right") {
                                        // Bar is on the right, prefer opening submenus to the left
                                        openLeft = true
                                    } else if (barPosition === "left") {
                                        // Bar is on the left, prefer opening submenus to the right
                                        openLeft = false
                                    } else {
                                        // Bar is horizontal (top/bottom) or undefined, use space-based logic
                                        openLeft = (globalPos.x + entry.width + submenuWidth > screen.width)

                                        // Secondary check: ensure we don't open off-screen
                                        if (openLeft && globalPos.x - submenuWidth < 0) {
                                            // Would open off the left edge, force right opening
                                            openLeft = false
                                        } else if (!openLeft && globalPos.x + entry.width + submenuWidth > screen.width) {
                                            // Would open off the right edge, force left opening
                                            openLeft = true
                                        }
                                    }

                                    // Position with overlap
                                    const anchorX = openLeft ? -submenuWidth + overlap : entry.width - overlap

                                    // Create submenu
                                    entry.subMenu = Qt.createComponent("TrayMenu.qml").createObject(root, {
                                        "menu": modelData,
                                        "anchorItem": entry,
                                        "anchorX": anchorX,
                                        "anchorY": 0,
                                        "isSubMenu": true,
                                        "screen": screen
                                    })

                                    if (entry.subMenu) {
                                        entry.subMenu.showAt(entry, anchorX, 0)
                                    }
                                }
                            }

                            onExited: {
                                backgroundRect.color = "transparent"
                                Qt.callLater(() => {
                                    if (entry.subMenu && !entry.subMenu.isHovered) {
                                        entry.subMenu.hideMenu()
                                        entry.subMenu.destroy()
                                        entry.subMenu = null
                                    }
                                })
                            }
                        }
                    }

                    Component.onDestruction: {
                        if (subMenu) {
                            subMenu.destroy()
                            subMenu = null
                        }
                    }
                }
            }
        }
    }
}
