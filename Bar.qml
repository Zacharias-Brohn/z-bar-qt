import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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

            Process {
                id: ncProcess
                command: ["sh", "-c", `qs -p ${bar.root}/shell.qml ipc call root showCenter`]
                running: false
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 34
            color: "transparent"

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: Config.baseBgColor
                radius: 0

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
                            Layout.fillHeight: true
                            Layout.topMargin: 6
                            Layout.bottomMargin: 6
                            bar: bar
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

                        Text {
                            id: notificationCenterIcon
                            Layout.alignment: Qt.AlignVCenter
                            text: HasNotifications.hasNotifications ? "\uf4fe" : "\ue7f4"
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: 22
                            color: "white"
                            MouseArea {
                                anchors.fill: parent
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
