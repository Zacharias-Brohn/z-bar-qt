import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Daemons

Repeater {
    id: groupListView
    model: ScriptModel {
        id: groupModel
        values: groupColumn.isExpanded ? groupColumn.notifications : groupColumn.notifications.slice( 0, 1 )
    }

    Rectangle {
        id: groupHeader
        required property int index
        required property NotifServer.Notif modelData
        property alias notifHeight: groupHeader.height

        property bool previewHidden: groupColumn.shouldShow && index > 0

        width: parent.width
        height: contentColumn.height + 20
        color: Config.baseBgColor
        border.color: "#555555"
        border.width: 1
        radius: 8
        opacity: previewHidden ? 0 : 1.0
        scale: previewHidden ? 0.7 : 1.0

        Component.onCompleted: modelData.lock(this);
        Component.onDestruction: modelData.unlock(this);

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if ( groupColumn.isExpanded || groupColumn.notifications.length === 1 ) {
                    if ( groupHeader.modelData.actions.length === 1 ) {
                        groupHeader.modelData.actions[0].invoke();
                    }
                } else {
                    groupColumn.shouldShow = true;
                    groupColumn.isExpanded = true;
                }
            }
        }

        ParallelAnimation {
            id: collapseAnim
            running: !groupColumn.shouldShow && index > 0

            Anim {
                target: groupHeader
                property: "opacity"
                duration: 100
                from: 1
                to: index > 0 ? 0 : 1.0
            }
            Anim {
                target: groupHeader
                property: "scale"
                duration: 100
                from: 1
                to: index > 0 ? 0.7 : 1.0
            }
            onFinished: {
                groupColumn.isExpanded = false;
            }
        }

        ParallelAnimation {
            running: groupHeader.modelData.closed
            onFinished: groupHeader.modelData.unlock(groupHeader)

            Anim {
                target: groupHeader
                property: "opacity"
                to: 0
            }
            Anim {
                target: groupHeader
                property: "x"
                to: groupHeader.x >= 0 ? groupHeader.width : -groupHeader.width
            }
        }

        Behavior on opacity {
            Anim {}
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on x {
            Anim {
                duration: MaterialEasing.expressiveDefaultSpatialTime
                easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
            }
        }

        Behavior on y {
            Anim {
                duration: MaterialEasing.expressiveDefaultSpatialTime
                easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
            }
        }

        Behavior on height {
            Anim {
                duration: MaterialEasing.expressiveDefaultSpatialTime
                easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
            }
        }

        Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - 20
            spacing: 10
            RowLayout {
                width: parent.width
                spacing: 10

                IconImage {
                    source: groupHeader.modelData.image
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    Layout.topMargin: 5
                    visible: groupHeader.modelData.image !== ""
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 2

                    Text {
                        text: groupHeader.modelData.summary
                        color: "white"
                        font.bold: true
                        font.pointSize: 16
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: groupHeader.modelData.body
                        font.pointSize: 12
                        color: "#dddddd"
                        elide: Text.ElideRight
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 20
                        wrapMode: Text.WordWrap
                        maximumLineCount: 5
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                Text {
                    text: groupColumn.notifications.length > 1 ? ( groupColumn.isExpanded ? "" : "(" + groupColumn.notifications.length + ")" ) : ""
                    font.pointSize: 10
                    color: "#666666"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }

            RowLayout {
                id: actionRow
                property NotifServer.Notif notif: groupHeader.modelData
                spacing: 2
                visible: groupHeader.modelData.actions.length > 1 ? true : false
                height: 30
                width: parent.width

                Repeater {
                    model: [ ...actionRow.notif.actions ]
                    Rectangle {
                        id: actionButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        required property var modelData
                        color: buttonArea.containsMouse ? "#15FFFFFF" : "#09FFFFFF"
                        radius: 4
                        Text {
                            anchors.centerIn: parent
                            text: actionButton.modelData.text
                            color: "white"
                            font.pointSize: 12
                        }
                        MouseArea {
                            id: buttonArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                console.log( groupHeader.modelData.actions );
                                actionButton.modelData.invoke();
                            }
                        }
                    }
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
                    groupColumn.isExpanded ? groupHeader.modelData.close() : groupColumn.closeAll();
                }
            }
        }
    }
}
