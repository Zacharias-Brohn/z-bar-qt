import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Config

Item {
    id: contextMenu

    anchors.fill: parent
    z: 999
    visible: false

    property string targetFilePath: ""
    property bool targetIsDir: false
    property var targetAppEntry: null

    property var targetPaths: []

    signal openFileRequested(string path, bool isDir)
    signal renameRequested(string path)

    property real menuX: 0
    property real menuY: 0

    CustomClippingRect {
        id: popupBackground
        readonly property real padding: Appearance.padding.small

        x: contextMenu.menuX
        y: contextMenu.menuY

        color: DynamicColors.tPalette.m3surface
        radius: Appearance.rounding.normal

        implicitWidth: menuLayout.implicitWidth + padding * 2
        implicitHeight: menuLayout.implicitHeight + padding * 2

        Behavior on opacity { Anim {} }
        opacity: contextMenu.visible ? 1 : 0

        ColumnLayout {
            id: menuLayout
            anchors.centerIn: parent
            spacing: 0

            CustomRect {
                Layout.preferredWidth: 160
                radius: popupBackground.radius - popupBackground.padding
                implicitHeight: openRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: openRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: "open_in_new"; font.pointSize: 20 }
                    CustomText { text: "Open"; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

                    onClicked: {
                        for (let i = 0; i < contextMenu.targetPaths.length; i++) {
                            let p = contextMenu.targetPaths[i];
                            if (p === contextMenu.targetFilePath) {
                                if (p.endsWith(".desktop") && contextMenu.targetAppEntry) contextMenu.targetAppEntry.execute()
                                else contextMenu.openFileRequested(p, contextMenu.targetIsDir)
                            } else {
                                Quickshell.execDetached(["xdg-open", p])
                            }
                        }
                        contextMenu.close()
                    }
                }
            }

            CustomRect {
                Layout.fillWidth: true
                radius: popupBackground.radius - popupBackground.padding
                implicitHeight: openWithRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: openWithRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: contextMenu.targetIsDir ? "terminal" : "apps"; font.pointSize: 20 }
                    CustomText { text: contextMenu.targetIsDir ? "Open in terminal" : "Open with..."; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

					onClicked: {
						if (contextMenu.targetIsDir) {
							Quickshell.execDetached([Config.general.apps.terminal, "--working-directory", contextMenu.targetFilePath])
						} else {
							Quickshell.execDetached(["xdg-open", contextMenu.targetFilePath])
						}
						contextMenu.close()
					}
                }
            }

            CustomRect {
                Layout.fillWidth: true
                implicitHeight: 1
                color: DynamicColors.palette.m3outlineVariant
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            CustomRect {
                Layout.fillWidth: true
                radius: popupBackground.radius - popupBackground.padding
                implicitHeight: copyPathRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: copyPathRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: "content_copy"; font.pointSize: 20 }
                    CustomText { text: "Copy path"; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

                    onClicked: {
                        Quickshell.execDetached(["wl-copy", contextMenu.targetPaths.join("\n")])
                        contextMenu.close()
                    }
                }
            }

            CustomRect {
                Layout.fillWidth: true
                visible: contextMenu.targetPaths.length === 1
                radius: popupBackground.radius - popupBackground.padding
                implicitHeight: renameRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: renameRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: "edit"; font.pointSize: 20 }
                    CustomText { text: "Rename"; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

                    onClicked: {
                        contextMenu.renameRequested(contextMenu.targetFilePath)
                        contextMenu.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: DynamicColors.palette.m3outlineVariant
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            CustomRect {
                Layout.fillWidth: true
                radius: popupBackground.radius - popupBackground.padding
                implicitHeight: deleteRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: deleteRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon {
                        text: "delete"
                        font.pointSize: 20
                        color: deleteButton.hovered ? DynamicColors.palette.m3onError : DynamicColors.palette.m3error
                    }

                    CustomText {
                        text: "Move to trash"
                        Layout.fillWidth: true
                        color: deleteButton.hovered ? DynamicColors.palette.m3onError : DynamicColors.palette.m3error
                    }
                }

                StateLayer {
                    id: deleteButton
                    anchors.fill: parent
                    color: DynamicColors.tPalette.m3error

                    onClicked: {
                        let cmd = ["gio", "trash"].concat(contextMenu.targetPaths)
                        Quickshell.execDetached(cmd)
                        contextMenu.close()
                    }
                }
            }
        }
    }

    function openAt(mouseX, mouseY, path, isDir, appEnt, parentW, parentH, selectionArray) {
        targetFilePath = path
        targetIsDir = isDir
        targetAppEntry = appEnt

        targetPaths = (selectionArray && selectionArray.length > 0) ? selectionArray : [path]

        menuX = Math.floor(Math.min(mouseX, parentW - popupBackground.implicitWidth))
        menuY = Math.floor(Math.min(mouseY, parentH - popupBackground.implicitHeight))

        visible = true
    }

    function close() {
        visible = false
    }
}
