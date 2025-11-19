import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQuick
import qs.Config
import qs.Daemons
import qs.Helpers
import qs.Effects

PanelWindow {
    id: root
    color: "transparent"
    screen: root.bar.screen
    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    mask: Region { regions: root.notifRegions }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    property list<Region> notifRegions: []
    required property bool centerShown
    required property PanelWindow bar
    visible: Hyprland.monitorFor(screen).focused

    Component.onCompleted: {
        console.log(NotifServer.list.filter( n => n.popup ).length + " notification popups loaded.");
    }

    ListView {
        id: notifListView
        model: ScriptModel {
            values: NotifServer.list.filter( n => n.popup )
            onValuesChanged: {
                if ( values.length === 0 )
                    root.notifRegions = [];
            }
        }
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: root.centerShown ? root.bar.width - width - 420 : root.bar.width - width - 20
        z: 0
        anchors.topMargin: 54
        width: 400
        spacing: 10

        Behavior on x {
            NumberAnimation {
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        displaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        remove: Transition {
            id: hideTransition
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    property: "x"
                    to: hideTransition.ViewTransition.destination.x + 200
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }

        add: Transition {
            id: showTransition
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    property: "x"
                    from: showTransition.ViewTransition.destination.x + 200
                    to: showTransition.ViewTransition.destination.x
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }

        component NotifRegion: Region { }

        Component {
            id: notifRegion
            NotifRegion {}
        }

        delegate: Item {
            id: rootItem
            implicitWidth: 400
            implicitHeight: contentLayout.childrenRect.height + 16
            required property NotifServer.Notif modelData

            ShadowRect {
                anchors.fill: backgroundRect
                radius: backgroundRect.radius
            }

            Rectangle {
                id: backgroundRect
                implicitWidth: 400
                implicitHeight: contentLayout.childrenRect.height + 16
                color: Config.baseBgColor
                border.color: "#555555"
                radius: 8

                Component.onCompleted: {
                    root.notifRegions.push( notifRegion.createObject(root, { item: backgroundRect }));
                }

                Column {
                    id: contentLayout
                    z: 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    spacing: 8
                    RowLayout {
                        spacing: 12
                        IconImage {
                            source: rootItem.modelData.image === "" ? Qt.resolvedUrl(rootItem.modelData.appIcon) : Qt.resolvedUrl(rootItem.modelData.image)
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
                            // visible: rootItem.modelData.image !== ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 0
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                            Text {
                                text: rootItem.modelData.appName
                                color: "white"
                                font.bold: true
                                font.pointSize: 14
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: rootItem.modelData.summary
                                color: "white"
                                font.pointSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                        }
                    }
                    Text {
                        text: rootItem.modelData.body
                        color: "#dddddd"
                        font.pointSize: 14
                        textFormat: Text.MarkdownText
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        maximumLineCount: 4
                        width: parent.width
                        linkColor: Config.accentColor.accents.primaryAlt

                        onLinkActivated: link => {
                            Quickshell.execDetached(["app2unit", "-O", "--", link]);
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: 6
                    anchors.topMargin: 6
                    width: 18
                    height: 18
                    color: closeArea.containsMouse ? "#FF6077" : "transparent"
                    radius: 9

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeArea.containsMouse ? "white" : "#888888"
                        font.pointSize: 12
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            rootItem.modelData.close();
                        }
                    }
                }

                ElapsedTimer {
                    id: timer
                }

            }
            MouseArea {
                z: 1
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    rootItem.modelData.timer.stop();
                }
                onExited: {
                    rootItem.modelData.timer.start();
                }
            }
        }
    }
}
