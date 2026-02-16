pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

ColumnLayout {
    id: root

    required property var lock

    anchors.fill: parent
    anchors.margins: Appearance.padding.large

    spacing: Appearance.spacing.smaller

    CustomText {
        Layout.fillWidth: true
        text: NotifServer.list.length > 0 ? qsTr("%1 notification%2").arg(NotifServer.list.length).arg(NotifServer.list.length === 1 ? "" : "s") : qsTr("Notifications")
        color: DynamicColors.palette.m3outline
        font.family: Appearance.font.family.mono
        font.weight: 500
        elide: Text.ElideRight
    }

    ClippingRectangle {
        id: clipRect

        Layout.fillWidth: true
        Layout.fillHeight: true

        radius: Appearance.rounding.small
        color: "transparent"

        Loader {
            anchors.centerIn: parent
            active: opacity > 0
            opacity: NotifServer.list.length > 0 ? 0 : 1

            sourceComponent: ColumnLayout {
                spacing: Appearance.spacing.large

                Image {
                    asynchronous: true
                    source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/dino.png`)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: clipRect.width * 0.8

                    layer.enabled: true
                    layer.effect: Coloriser {
                        colorizationColor: DynamicColors.palette.m3outlineVariant
                        brightness: 1
                    }
                }

                CustomText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No Notifications")
                    color: DynamicColors.palette.m3outlineVariant
                    font.pointSize: Appearance.font.size.large
                    font.family: Appearance.font.family.mono
                    font.weight: 500
                }
            }

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.extraLarge
                }
            }
        }

        CustomListView {
            anchors.fill: parent

            spacing: Appearance.spacing.small
            clip: true

            model: ScriptModel {
                values: {
                    const list = NotifServer.notClosed.map(n => [n.appName, null]);
                    return [...new Map(list).keys()];
                }
            }

            delegate: NotifGroup {}

            add: Transition {
                Anim {
                    property: "opacity"
                    from: 0
                    to: 1
                }
                Anim {
                    property: "scale"
                    from: 0
                    to: 1
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }

            remove: Transition {
                Anim {
                    property: "opacity"
                    to: 0
                }
                Anim {
                    property: "scale"
                    to: 0.6
                }
            }

            move: Transition {
                Anim {
                    properties: "opacity,scale"
                    to: 1
                }
                Anim {
                    property: "y"
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }

            displaced: Transition {
                Anim {
                    properties: "opacity,scale"
                    to: 1
                }
                Anim {
                    property: "y"
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }
        }
    }
}
