import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Components
import qs.Config
import qs.Paths

Item {
    id: root
    
    anchors.fill: parent
    z: 998
    visible: false
    
    property real menuX: 0
    property real menuY: 0
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    CustomClippingRect {
        id: popupBackground
        readonly property real padding: 4
        
        x: root.menuX
        y: root.menuY
        
        color: DynamicColors.tPalette.m3surface
        radius: Appearance.rounding.normal
        
        implicitWidth: menuLayout.implicitWidth + padding * 2
        implicitHeight: menuLayout.implicitHeight + padding * 2
        
        Behavior on opacity { Anim {} }
        opacity: root.visible ? 1 : 0
        
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
                    MaterialIcon { text: "terminal"; font.pointSize: 20 }
                    CustomText { text: "Open terminal"; Layout.fillWidth: true }
                }
                
                onClicked: {
                    Quickshell.execDetached([Config.general.apps.terminal, "--working-directory", FileUtils.trimFileProtocol(Paths.desktop)])
                    root.close()
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
                    MaterialIcon { text: "settings"; font.pointSize: 20 }
                    CustomText { text: "Sleex settings"; Layout.fillWidth: true }
                }
                
                onClicked: {
                    Quickshell.execDetached(["qs", "-p", "/usr/share/sleex/settings.qml"])
                    root.close()
                }
            }

            CustomRect {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            StateLayer {
                Layout.fillWidth: true
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon { text: "logout"; font.pointSize: 20 }
                    CustomText { text: "Logout"; Layout.fillWidth: true }
                }
                
                onClicked: {
                    Hyprland.dispatch("global quickshell:sessionOpen")
                    root.close()
                }
            }

            CustomRect {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.m3colors.m3outlineVariant
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            StateLayer {
                Layout.fillWidth: true
                
                contentItem: RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 12
                    MaterialIcon { text: Config.options.background.showDesktopIcons ? "visibility_off" : "visibility"; font.pointSize: 20 }
                    CustomText { text: Config.options.background.showDesktopIcons ? "Hide icons" : "Show icons"; Layout.fillWidth: true }
                }

                onClicked: {
                    Config.options.background.showDesktopIcons = !Config.options.background.showDesktopIcons
                    root.close()
                }
            }
        }
    }
    
    function openAt(mouseX, mouseY, parentW, parentH) {
        menuX = Math.min(mouseX, parentW - popupBackground.implicitWidth)
        menuY = Math.min(mouseY, parentH - popupBackground.implicitHeight)
        visible = true
    }
    
    function close() {
        visible = false
    }
}
