import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Components
import qs.Config
import qs.Paths
import qs.Helpers

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
            anchors.centerIn: parent
            spacing: 0

            CustomRect {
                Layout.preferredWidth: 200
                radius: popupBackground.radius - popupBackground.padding
                implicitHeight: openTerminalRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: openTerminalRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: "terminal"; font.pointSize: 20 }
                    CustomText { text: "Open terminal"; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

                    onClicked: {
                        Quickshell.execDetached([Config.general.apps.terminal, "--working-directory", FileUtils.trimFileProtocol(Paths.desktop)])
                        root.close()
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
                implicitHeight: settingsRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: settingsRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: "settings"; font.pointSize: 20 }
                    CustomText { text: "ZShell settings"; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

                    onClicked: {
                        const visibilities = Visibilities.getForActive();
						visibilities.settings = true;
                        root.close()
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
                implicitHeight: logoutRow.implicitHeight + Appearance.padding.small * 2

                RowLayout {
                    id: logoutRow
                    spacing: 8
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.smaller

                    MaterialIcon { text: "logout"; font.pointSize: 20 }
                    CustomText { text: "Logout"; Layout.fillWidth: true }
                }

                StateLayer {
                    anchors.fill: parent

                    onClicked: {
                        Hyprland.dispatch("global quickshell:sessionOpen")
                        root.close()
                    }
                }
            }

            // CustomRect {
            //     Layout.fillWidth: true
            //     implicitHeight: 1
            //     color: DynamicColors.palette.m3outlineVariant
            //     Layout.topMargin: 4
            //     Layout.bottomMargin: 4
            // }
            //
            // CustomRect {
            //     Layout.fillWidth: true
            //     radius: popupBackground.radius - popupBackground.padding
            //     implicitHeight: desktopIconsRow.implicitHeight + Appearance.padding.small * 2
            //
            //     RowLayout {
            //         id: desktopIconsRow
            //         spacing: 8
            //         anchors.fill: parent
            //         anchors.leftMargin: Appearance.padding.smaller
            //
            //         MaterialIcon { text: Config.options.background.showDesktopIcons ? "visibility_off" : "visibility"; font.pointSize: 20 }
            //         CustomText { text: Config.options.background.showDesktopIcons ? "Hide icons" : "Show icons"; Layout.fillWidth: true }
            //     }
            //
            //     StateLayer {
            //         anchors.fill: parent
            //
            //         onClicked: {
            //             Config.options.background.showDesktopIcons = !Config.options.background.showDesktopIcons
            //             root.close()
            //         }
            //     }
            // }
        }
    }

    function openAt(mouseX, mouseY, parentW, parentH) {
        menuX = Math.floor(Math.min(mouseX, parentW - popupBackground.implicitWidth))
        menuY = Math.floor(Math.min(mouseY, parentH - popupBackground.implicitHeight))
        visible = true
    }

    function close() {
        visible = false
    }
}
