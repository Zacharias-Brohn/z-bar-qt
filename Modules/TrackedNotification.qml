import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick
import Quickshell.Services.Notifications
import qs.Config

PanelWindow {
    id: root
    color: "transparent"
    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }
    mask: Region { item: backgroundRect }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    required property Notification notif
    required property int centerX
    required property list<int> notifIndex
    required property list<TrackedNotification> notifList
    property int index: notifIndex.indexOf(notif.id)
    property alias y: backgroundRect.y
    property alias notifHeight: backgroundRect.implicitHeight
    signal notifDestroy()

    Component.onCompleted: {
        openAnim.start();
        console.log(root.index);
    }

    Timer {
        id: timeout
        interval: 5000
        onTriggered: {
            closeAnim.start();
        }
    }

    NumberAnimation {
        id: openAnim
        target: backgroundRect
        property: "x"
        from: root.centerX
        to: root.centerX - backgroundRect.implicitWidth - 20
        duration: 200
        easing.type: Easing.InOutQuad
        onStopped: { timeout.start(); }
    }

    NumberAnimation {
        id: closeAnim
        target: backgroundRect
        property: "x"
        from: root.centerX - backgroundRect.implicitWidth - 20
        to: root.centerX
        duration: 200
        easing.type: Easing.InOutQuad
        onStopped: {
            root.destroy();
            root.notifDestroy();
        }
    }

    Rectangle {
        id: backgroundRect
        implicitWidth: 400
        implicitHeight: contentLayout.childrenRect.height + 16
        x: root.centerX - implicitWidth - 20
        y: !root.notifList[ root.index - 1 ] ? 34 + 20 : root.notifList[ root.index - 1 ].y + root.notifList[ root.index - 1 ].notifHeight + 10
        color: Config.baseBgColor
        border.color: "#555555"
        radius: 8

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Column {
            id: contentLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            spacing: 8
            RowLayout {
                spacing: 12
                IconImage {
                    source: root.notif.image
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
                    visible: root.notif.image !== ""
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 0
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    Text {
                        text: root.notif.appName
                        color: "white"
                        font.bold: true
                        font.pointSize: 14
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.notif.summary
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
                text: root.notif.body
                color: "#dddddd"
                font.pointSize: 14
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                width: parent.width
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
                    root.notif.dismiss();
                    root.visible = false;
                }
            }
        }
    }
}
