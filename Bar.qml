import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import qs.Modules

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 34
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#801a1a1a"
                radius: 0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5

                    RowLayout {
                        id: leftSection
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100

                        Workspaces {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.topMargin: 6
                            Layout.bottomMargin: 6
                            screen: bar.screen
                        }

                        AudioWidget {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.topMargin: 6
                            Layout.bottomMargin: 6
                        }

                        Resources {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.topMargin: 6
                            Layout.bottomMargin: 6
                        }

                        UpdatesWidget {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.topMargin: 6
                            Layout.bottomMargin: 6
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

                        SwayNC {
                            Layout.alignment: Qt.AlignVCenter
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
