import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Modules
import qs.Config
import qs.Helpers

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            property bool trayMenuVisible: false
            screen: modelData
            property var root: Quickshell.shellDir
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            PanelWindow {
                id: wrapper
                screen: bar.screen
                WlrLayershell.layer: WlrLayer.Bottom
                anchors {
                    left: true
                    right: true
                    top: true
                }
                color: "transparent"
                implicitHeight: 34
            }

            NotificationCenter {
                bar: bar
            }

            Process {
                id: ncProcess
                command: ["sh", "-c", `qs -p ${bar.root}/shell.qml ipc call root showCenter`]
                running: false
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            mask: Region { item: backgroundRect }

            color: "transparent"

            Rectangle {
                id: backgroundRect
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                implicitHeight: 34
                color: Config.useDynamicColors ? DynamicColors.tPalette.m3surface : Config.baseBgColor
                radius: 0

                Behavior on color {
                    CAnim {}
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5

                    RowLayout {
                        id: leftSection
                        Layout.fillHeight: true
                        Layout.preferredWidth: leftSection.childrenRect.width

                        Workspaces {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            bar: bar
                        }

                        AudioWidget {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        }

                        Resources {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        }

                        UpdatesWidget {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            countUpdates: Updates.availableUpdates
                        }
                    }

                    RowLayout {
                        id: centerSection
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    }

                    RowLayout {
                        id: rightSection
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                        TrayWidget {
                            id: systemTrayModule
                            bar: bar
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Clock {
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            id: notificationCenterIcon
                            property color iconColor: Config.useDynamicColors ? DynamicColors.palette.m3tertiaryFixed : "white"
                            Layout.alignment: Qt.AlignVCenter
                            text: HasNotifications.hasNotifications ? "\uf4fe" : "\ue7f4"
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: 20
                            color: iconColor

                            Behavior on color {
                                CAnim {}
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    ncProcess.running = true
                                }
                            }
                        }
                    }
                }
                WindowTitle {
                    anchors.centerIn: parent
                    width: Math.min( 300, parent.width * 0.4 )
                    height: parent.height
                    z: 1
                }
            }
        }
    }
}
