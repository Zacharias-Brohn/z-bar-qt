import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import QtQuick
import Quickshell.Services.Notifications
import qs.Config
import qs.Helpers
import qs.Daemons

PanelWindow {
    id: root
    color: "transparent"
    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }
    property bool centerShown: false
    property alias posX: backgroundRect.x
    property alias doNotDisturb: dndSwitch.checked
    visible: false

    mask: Region { item: backgroundRect }

    IpcHandler {
        id: ipcHandler
        target: "root"

        function showCenter(): void { root.centerShown = !root.centerShown; }
    }

    onVisibleChanged: {
        if ( root.visible ) {
            showAnimation.start();
        }
    }

    onCenterShownChanged: {
        if ( !root.centerShown ) {
            closeAnimation.start();
            closeTimer.start();
        } else {
            root.visible = true;
        }
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            root.visible = false;
        }
    }

    NumberAnimation {
        id: showAnimation
        target: backgroundRect
        property: "x"
        from: Screen.width
        to: Screen.width - backgroundRect.implicitWidth - 10
        duration: 300
        easing.type: Easing.OutCubic
        onStopped: {
            focusGrab.active = true;
        }
    }

    NumberAnimation {
        id: closeAnimation
        target: backgroundRect
        property: "x"
        from: Screen.width - backgroundRect.implicitWidth - 10
        to: Screen.width
        duration: 300
        easing.type: Easing.OutCubic
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: [ root ]
        onCleared: {
            root.centerShown = false;
        }
    }

    Rectangle {
        id: backgroundRect
        y: 10
        x: Screen.width
        implicitWidth: 400
        implicitHeight: root.height - 20
        color: Config.baseBgColor
        radius: 8
        border.color: "#555555"
        border.width: 1
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Switch {
                    id: dndSwitch
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    text: "Do Not Disturb"
                    focus: false
                    activeFocusOnTab: false
                    focusPolicy: Qt.NoFocus
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Text {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        text: "Clear all"
                        color: "white"
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        color: clearArea.containsMouse ? "#15FFFFFF" : "transparent"
                        radius: 4
                        Text {
                            anchors.centerIn: parent
                            text: "\ue0b8"
                            font.family: "Material Symbols Rounded"
                            font.pointSize: 18
                            color: "white"
                        }
                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                for ( const n of NotifServer.notClosed )
                                    n.close();
                            }
                        }
                    }
                }
            }

            Rectangle {
                color: "#333333"
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                pixelAligned: true
                contentHeight: notificationColumn.implicitHeight
                clip: true

                Column {
                    id: notificationColumn
                    width: parent.width
                    spacing: 10

                    add: Transition {
                        NumberAnimation {
                            properties: "x";
                            duration: 300;
                            easing.type: Easing.OutCubic
                        }
                    }

                    move: Transition {
                        NumberAnimation {
                            properties: "y,x";
                            duration: 200;
                            easing.type: Easing.OutCubic
                        }
                    }

                    Repeater {
                        model: ScriptModel {
                            values: {
                                const map = new Map();
                                for ( const n of NotifServer.notClosed )
                                    map.set( n.appName, null );
                                for ( const n of NotifServer.list )
                                    map.set( n.appName, null );
                                return [ ...map.keys() ];
                            }
                            onValuesChanged: {
                                root.flagChanged();
                            }
                        }
                        Column {
                            id: groupColumn
                            required property string modelData
                            property list<var> notifications: NotifServer.list.filter( n => n.appName === modelData )
                            width: parent.width
                            spacing: 10

                            property bool shouldShow: false
                            property bool isExpanded: false

                            function closeAll(): void {
                                for ( const n of NotifServer.notClosed.filter( n => n.appName === modelData ))
                                    n.close();
                            }

                            Behavior on height {
                                Anim {}
                            }

                            // add: Transition {
                            //     id: addTrans
                            //     SequentialAnimation {
                            //         PauseAnimation {
                            //             duration: ( addTrans.ViewTransition.index - addTrans.ViewTransition.targetIndexes[ 0 ]) * 50
                            //         }
                            //         ParallelAnimation {
                            //             NumberAnimation {
                            //                 properties: "y";
                            //                 from: addTrans.ViewTransition.destination.y - (height / 2);
                            //                 to: addTrans.ViewTransition.destination.y;
                            //                 duration: 100;
                            //                 easing.type: Easing.OutCubic
                            //             }
                            //             NumberAnimation {
                            //                 properties: "opacity";
                            //                 from: 0;
                            //                 to: 1;
                            //                 duration: 100;
                            //                 easing.type: Easing.OutCubic
                            //             }
                            //         }
                            //     }
                            // }
                            //
                            move: Transition {
                                id: moveTrans
                                NumberAnimation {
                                    properties: "y";
                                    duration: 100;
                                    easing.type: Easing.OutCubic
                                }
                            }

                            RowLayout {
                                width: parent.width
                                height: 30

                                Text {
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                    Layout.leftMargin: 5
                                    text: groupColumn.modelData
                                    color: "white"
                                    font.pointSize: 14
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 30
                                    color: collapseArea.containsMouse ? "#15FFFFFF" : "transparent"
                                    radius: 4
                                    visible: groupColumn.isExpanded
                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue944"
                                        font.family: "Material Symbols Rounded"
                                        font.pointSize: 18
                                        color: "white"
                                    }
                                    MouseArea {
                                        id: collapseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            groupColumn.isExpanded = false;
                                        }
                                    }
                                }
                            }

                            ListView {
                                id: groupListView
                                model: ScriptModel {
                                    id: groupModel
                                    values: groupColumn.isExpanded ? groupColumn.notifications : groupColumn.notifications.slice( 0, 1 )
                                }

                                width: parent.width
                                spacing: 10
                                height: contentHeight
                                contentHeight: childrenRect.height
                                clip: false

                                pixelAligned: true
                                boundsBehavior: Flickable.StopAtBounds
                                displayMarginBeginning: 0
                                displayMarginEnd: 5000

                                Behavior on height {
                                    Anim {
                                        duration: 20;
                                    }
                                }

                                add: Transition {
                                    id: add
                                    NumberAnimation {
                                        properties: "y,opacity";
                                        duration: 100 * ( add.ViewTransition.targetIndexes.length / ( add.ViewTransition.targetIndexes.length < 3 ? 1 : 3 ));
                                        easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                                    }
                                }

                                remove: Transition {
                                    NumberAnimation {
                                        properties: "opacity";
                                        from: 1;
                                        to: 0;
                                        duration: 300;
                                        easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                                    }
                                }

                                displaced: Transition {
                                    NumberAnimation {
                                        properties: "y";
                                        duration: 200;
                                        easing.bezierCurve: MaterialEasing.expressiveDefaultSpatial
                                    }
                                }

                                delegate: Rectangle {
                                    id: groupHeader
                                    required property int index
                                    required property NotifServer.Notif modelData
                                    property alias notifHeight: groupHeader.height

                                    property bool previewHidden: !groupColumn.isExpanded && index > 0

                                    width: groupListView.width
                                    height: contentColumn.height + 20
                                    color: Config.baseBgColor
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 8
                                    opacity: 1
                                    scale: 1.0

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
                                                groupColumn.isExpanded = true;
                                            }
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

                                    Column {
                                        id: contentColumn
                                        anchors.centerIn: parent
                                        width: parent.width - 20
                                        spacing: 10
                                        // anchors.left: parent.left
                                        // anchors.right: parent.right
                                        // anchors.leftMargin: 10
                                        // anchors.rightMargin: 10
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
                                            spacing: 2
                                            // visible: groupColumn.isExpanded ? ( groupHeader.modelData.actions.length > 1 ? true : false ) : ( groupColumn.notifications.length === 1 ? ( groupHeader.modelData.actions.length > 1 ? true : false ) : false )
                                            visible: true
                                            height: 30
                                            width: parent.width

                                            Repeater {
                                                model: groupHeader.modelData.actions
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
                        }
                    }
                }
            }
        }
    }
}
