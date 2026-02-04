pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Props props
    required property var visibilities
    readonly property int notifCount: NotifServer.list.reduce((acc, n) => n.closed ? acc : acc + 1, 0)

    anchors.fill: parent
    anchors.margins: 8

    Component.onCompleted: NotifServer.list.forEach(n => n.popup = false)

    Item {
        id: title

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4

        implicitHeight: Math.max(count.implicitHeight, titleText.implicitHeight)

        CustomText {
            id: count

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.notifCount > 0 ? 0 : -width - titleText.anchors.leftMargin
            opacity: root.notifCount > 0 ? 1 : 0

            text: root.notifCount
            color: DynamicColors.palette.m3outline
            font.pointSize: 13
            font.family: "CaskaydiaCove NF"
            font.weight: 500

            Behavior on anchors.leftMargin {
                Anim {}
            }

            Behavior on opacity {
                Anim {}
            }
        }

        CustomText {
            id: titleText

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: count.right
            anchors.right: parent.right
            anchors.leftMargin: 7

            text: root.notifCount > 0 ? qsTr("notification%1").arg(root.notifCount === 1 ? "" : "s") : qsTr("Notifications")
            color: DynamicColors.palette.m3outline
            font.pointSize: 13
            font.family: "CaskaydiaCove NF"
            font.weight: 500
            elide: Text.ElideRight
        }
    }

    ClippingRectangle {
        id: clipRect

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 10

        radius: 6
        color: "transparent"

        Loader {
            anchors.centerIn: parent
            active: opacity > 0
            opacity: root.notifCount > 0 ? 0 : 1

            sourceComponent: ColumnLayout {
                spacing: 20

                Image {
                    asynchronous: true
                    source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/dino.png`)
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: clipRect.width * 0.8
                }

                CustomText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No Notifications")
                    color: DynamicColors.palette.m3outlineVariant
                    font.pointSize: 18
                    font.family: "CaskaydiaCove NF"
                    font.weight: 500
                }
            }

            Behavior on opacity {
                Anim {
					duration: MaterialEasing.expressiveEffectsTime
                }
            }
        }

        CustomFlickable {
            id: view

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            contentWidth: width
            contentHeight: notifList.implicitHeight

            CustomScrollBar.vertical: CustomScrollBar {
                flickable: view
            }

            NotifDockList {
                id: notifList

                props: root.props
                visibilities: root.visibilities
                container: view
            }
        }
    }

    Timer {
        id: clearTimer

        repeat: true
        interval: 50
        onTriggered: {
            let next = null;
            for (let i = 0; i < notifList.repeater.count; i++) {
                next = notifList.repeater.itemAt(i);
                if (!next?.closed)
                    break;
            }
            if (next)
                next.closeAll();
            else
                stop();
        }
    }

    Loader {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8

        scale: root.notifCount > 0 ? 1 : 0.5
        opacity: root.notifCount > 0 ? 1 : 0
        active: opacity > 0

        sourceComponent: IconButton {
            id: clearBtn

            icon: "clear_all"
            radius: 8
            padding: 8
            font.pointSize: Math.round(18 * 1.2)
            onClicked: clearTimer.start()

            Elevation {
                anchors.fill: parent
                radius: parent.radius
                z: -1
                level: clearBtn.stateLayer.containsMouse ? 4 : 3
            }
        }

        Behavior on scale {
            Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        Behavior on opacity {
            Anim {
				duration: MaterialEasing.expressiveEffectsTime
            }
        }
    }
}
