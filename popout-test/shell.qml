import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Caelestia
import QtQuick
import QtQuick.Layouts
import qs.modules

Variants {
    model: Quickshell.screens

    Scope {
        id: scope
        required property ShellScreen modelData

        PanelWindow {
            screen: scope.modelData
            color: "#99000000"
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 34

            Rectangle {
                anchors.centerIn: parent
                implicitHeight: parent.height
                implicitWidth: rowL.implicitWidth + 10
                color: "transparent"
                RowLayout {
                    spacing: 8
                    id: rowL
                    anchors.centerIn: parent
                    Repeater {
                        model: SystemTray.items
                        MouseArea {
                            id: trayItem
                            required property SystemTrayItem modelData
                            property SystemTrayItem item: modelData
                            implicitWidth: 20
                            implicitHeight: 20

                            hoverEnabled: true
                            acceptedButtons: Qt.RightButton | Qt.LeftButton

                            IconImage {
                                id: icon

                                anchors.fill: parent
                                layer.enabled: true

                                layer.onEnabledChanged: {
                                    if (layer.enabled && status === Image.Ready) 
                                        analyser.requestUpdate();
                                }

                                onStatusChanged: {
                                    if (layer.enabled && status === Image.Ready) 
                                        analyser.requestUpdate();
                                }

                                source: GetIcons.getTrayIcon(trayItem.item.id, trayItem.item.icon)

                                mipmap: false
                                asynchronous: true
                                ImageAnalyser {
                                    id: analyser
                                    sourceItem: icon
                                }
                            }
                            Popout {
                                id: popout
                                menu: trayItem.item.menu
                                anchor.item: trayItem
                                anchor.edges: Edges.Bottom | Edges.Left
                            }
                            onClicked: {
                                if ( mouse.button === Qt.LeftButton ) {
                                    trayItem.item.activate();
                                } else if ( mouse.button === Qt.RightButton ) {
                                    popout.visible = !popout.visible;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
