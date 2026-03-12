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
    
    MouseArea {
        anchors.fill: parent
        onClicked: contextMenu.close()
    }

    CustomClippingRect {
        id: popupBackground
        readonly property real padding: 4
        
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
            anchors.fill: parent
            anchors.margins: popupBackground.padding
            spacing: 0

            StateLayer {
                Layout.fillWidth: true
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon { text: "open_in_new"; font.pointSize: 20 }
                    CustomText { text: "Open"; Layout.fillWidth: true }
                }
                
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

            StateLayer {
                Layout.fillWidth: true
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon { text: contextMenu.targetIsDir ? "terminal" : "apps"; font.pointSize: 20 }
                    CustomText { text: contextMenu.targetIsDir ? "Open in terminal" : "Open with..."; Layout.fillWidth: true }
                }
                
                onClicked: {
					Quickshell.execDetached(["xdg-open", contextMenu.targetFilePath])
                    contextMenu.close()
                }
            }

            CustomRect {
                Layout.fillWidth: true
                implicitHeight: 1
                color: DynamicColors.palette.m3outlineVariant
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            StateLayer {
                Layout.fillWidth: true
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon { text: "content_copy"; font.pointSize: 20 }
                    CustomText { text: "Copy path"; Layout.fillWidth: true }
                }
                
                onClicked: {
                    Quickshell.execDetached(["wl-copy", contextMenu.targetPaths.join("\n")])
                    contextMenu.close()
                }
            }

            StateLayer {
                Layout.fillWidth: true
                visible: contextMenu.targetPaths.length === 1
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon { text: "edit"; font.pointSize: 20 }
                    CustomText { text: "Rename"; Layout.fillWidth: true }
                }
                
                onClicked: {
                    contextMenu.renameRequested(contextMenu.targetFilePath)
                    contextMenu.close()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            StateLayer {
                id: deleteButton
                Layout.fillWidth: true
                colBackgroundHover: Appearance.colors.colError
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon {
                        text: "delete";
                        font.pointSize: 20;
                        color: deleteButton.hovered ? Appearance.colors.colOnError : Appearance.colors.colError
                    }
                    CustomText {
                        text: "Move to trash";
                        Layout.fillWidth: true;
                        color: deleteButton.hovered ? Appearance.colors.colOnError : Appearance.colors.colError
                    }
                }
                
                onClicked: {
                    let cmd = ["gio", "trash"].concat(contextMenu.targetPaths)
                    Quickshell.execDetached(cmd)
                    contextMenu.close()
                }
            }
        }
    }
    
    function openAt(mouseX, mouseY, path, isDir, appEnt, parentW, parentH, selectionArray) {
        targetFilePath = path
        targetIsDir = isDir
        targetAppEntry = appEnt
        
        targetPaths = (selectionArray && selectionArray.length > 0) ? selectionArray : [path]
        
        menuX = Math.min(mouseX, parentW - popupBackground.implicitWidth)
        menuY = Math.min(mouseY, parentH - popupBackground.implicitHeight)
        
        visible = true
    }
    
    function close() {
        visible = false
    }
}
