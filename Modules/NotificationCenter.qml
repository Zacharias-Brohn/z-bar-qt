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

PanelWindow {
    id: root
    color: "transparent"
    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }
    required property list<Notification> notifications
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

    QtObject {
        id: groupedData
        property var groups: ({})

        function updateGroups() {
            var newGroups = {};
            for ( var i = 0; i < root.notifications.length; i++ ) {
                var notif = root.notifications[ i ];
                var appName = notif.appName || "Unknown";
                if ( !newGroups[ appName ]) {
                    newGroups[ appName ] = [];
                }
                newGroups[ appName ].push( notif );
            }
            // Sort notifications within each group (latest first)
            for ( var app in newGroups ) {
                newGroups[ app ].sort(( a, b ) => b.receivedTime - a.receivedTime );
            }
            groups = newGroups;
            groupsChanged();
        }

        Component.onCompleted: updateGroups()
    }

    Connections {
        target: root
        function onNotificationsChanged() {
            groupedData.updateGroups();
        }
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
                                for ( var app in groupedData.groups ) {
                                    groupedData.groups[ app ].forEach( function( n ) { n.dismiss(); });
                                }
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
                        model: Object.keys( groupedData.groups )
                        Column {
                            id: groupColumn
                            required property string modelData
                            property var notifications: groupedData.groups[ modelData ]
                            width: parent.width
                            spacing: 10

                            property bool shouldShow: false
                            property bool isExpanded: false

                            move: Transition {
                                NumberAnimation {
                                    properties: "y,x";
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

                            Repeater {
                                model: groupColumn.notifications
                                Rectangle {
                                    id: groupHeader
                                    required property var modelData
                                    required property var index
                                    width: parent.width
                                    height: groupColumn.isExpanded ? ( modelData.actions.length > 1 ? 130 : 80 ) : ( groupColumn.notifications.length === 1 ? ( modelData.actions.length > 1 ? 130 : 80 ) : 80 )
                                    color: Config.baseBgColor
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 8
                                    visible: groupColumn.notifications[0].id === modelData.id || groupColumn.isExpanded

                                    Connections {
                                        target: groupColumn
                                        function onShouldShowChanged() {
                                            if ( !shouldShow ) {
                                                // collapseAnim.start();
                                            }
                                        }
                                    }

                                    onVisibleChanged: {
                                        if ( visible ) {
                                            // expandAnim.start();
                                        } else {
                                            groupColumn.isExpanded = false;
                                        }
                                    }

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

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        RowLayout {
                                            height: 80
                                            width: parent.width
                                            spacing: 10

                                            IconImage {
                                                source: groupHeader.modelData.image
                                                Layout.preferredWidth: 48
                                                Layout.preferredHeight: 48
                                                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                Layout.topMargin: 5
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 4

                                                Text {
                                                    text: groupHeader.modelData.summary
                                                    color: "white"
                                                    font.bold: true
                                                    font.pointSize: 12
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: groupHeader.modelData.body
                                                    font.pointSize: 10
                                                    color: "#dddddd"
                                                    elide: Text.ElideRight
                                                    lineHeightMode: Text.FixedHeight
                                                    lineHeight: 14
                                                    wrapMode: Text.WordWrap
                                                    maximumLineCount: 3
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
                                            visible: groupColumn.isExpanded ? ( groupHeader.modelData.actions.length > 1 ? true : false ) : ( groupColumn.notifications.length === 1 ? ( groupHeader.modelData.actions.length > 1 ? true : false ) : false )
                                            height: 15
                                            width: parent.width

                                            Repeater {
                                                model: groupHeader.modelData.actions
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 30
                                                    required property var modelData
                                                    color: buttonArea.containsMouse ? "#15FFFFFF" : "#09FFFFFF"
                                                    radius: 4
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.text
                                                        color: "white"
                                                        font.pointSize: 12
                                                    }
                                                    MouseArea {
                                                        id: buttonArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            modelData.invoke();
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
                                                groupColumn.isExpanded ? groupColumn.notifications[0].dismiss() : groupColumn.notifications.forEach( function( n ) { n.dismiss(); });
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
