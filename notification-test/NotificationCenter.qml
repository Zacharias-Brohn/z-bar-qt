pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import QtQuick
import Quickshell.Services.Notifications

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
    property alias groupedData: groupedData
    visible: false

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

    ListModel {
        id: groupedData
        property int totalCount: 0
        property var groupMap: ({})

        function mapGroups() {
            groupedData.groupMap = {};
            for ( var i = 0; i < groupedData.count; i++ ) {
                var name = get(i).name;
                groupMap[ name ] = i;
            }
        }

        function updateCount() {
            var count = 0;
            for ( var i = 0; i < groupedData.count; i++ ) {
                count += get(i).notifications.count;
            }
            totalCount = count;
        }

        function ensureGroup(appName) {
            for ( var i = 0; i < count; i++ ) {
                if ( get(i).name === appName ) {
                    return get(i).notifications;
                }
            }
            var model = Qt.createQmlObject('import QtQuick 2.0; ListModel {}', root);
            append({ name: appName, notifications: model });
            mapGroups();
            return model;
        }

        function addNotification(notif) {
            var appName = notif.appName
            var model = ensureGroup(appName);
            model.insert(0, notif);
            updateCount();
        }

        function removeNotification(notif) {
            var appName = notif.appName || "Unknown";
            var group = get( groupMap[ appName ]);
            if ( group.name === appName ) {
                root.notifications[ idMap[ notif.id ]].dismiss();
                if ( group.notifications.count === 0 ) {
                    remove( groupMap[ appName ], 1 );
                    mapGroups();
                }
            }
            updateCount();
        }

        function removeGroup(notif) {
            var appName = notif.appName || "Unknown";
            var group = get(groupMap[ appName ]);
            if ( group.name === appName ) {
                for ( var i = 0; i < group.notifications.count; i++ ) {
                    var item = group.notifications.get( i );
                    item.dismiss();
                }
                remove( groupMap[ appName ], 1 );
                updateCount();
                mapGroups();
            }
        }

        function resetGroups(notifications) {
            groupedData.clear();
            for (var i = 0; i < root.notifications.length; i++) {
                addNotification(root.notifications[i]);
            }
            updateCount();
        }

        Component.onCompleted: {
            resetGroups(root.notifications)
        }
    }

    Connections {
        target: root
        function onNotificationsChanged() {
            if ( root.notifications.length > groupedData.totalCount ) {
                groupedData.addNotification( root.notifications[ root.notifications.length - 1 ] );
                groupedData.mapGroups();
                console.log(root.notifications)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: {
            if ( root.centerShown ) {
                root.centerShown = false;
                console.log("groups", groupedData.count);
                console.log(root.notifications)
            }
        }
    }

    Rectangle {
        id: backgroundRect
        y: 10
        x: Screen.width
        implicitWidth: 400
        implicitHeight: root.height - 20
        color: "#801a1a1a"
        radius: 8
        border.color: "#555555"
        border.width: 1
        clip: true
        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                Layout.preferredHeight: 30
                Layout.fillWidth: true
                Text {
                    text: "Notifications"
                    color: "white"
                    font.bold: true
                    font.pointSize: 16
                    Layout.fillWidth: true
                }

                Switch {
                    id: dndSwitch
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    text: "Do Not Disturb"
                }
            }

            Rectangle {
                color: "#333333"
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }

            Column {
                id: notificationColumn
                Layout.fillHeight: true
                Layout.fillWidth: true
                // width: mainLayout.width
                spacing: 10
                clip: true

                move: Transition {
                    NumberAnimation {
                        properties: "y,x"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                add: Transition {
                    NumberAnimation {
                        properties: "y,x"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                ListView {
                    id: groupListView
                    model: groupedData
                    spacing: 10
                    width: 400
                    height: Math.min(contentHeight, notificationColumn.height)
                    // Layout.fillWidth: true
                    // Layout.fillHeight: true

                    delegate: ListView {
                        required property var modelData
                        required property int index
                        property bool isExpanded: false
                        property bool isExpandedAnim: false
                        id: listView
                        visible: true
                        property ListModel notificationsModel: modelData.notifications
                        model: notificationsModel
                        width: notificationColumn.width
                        implicitHeight: listView.isExpandedAnim ? contentHeight : 80
                        clip: true

                        spacing: 10

                        onIsExpandedChanged: {
                            if ( !isExpanded ) {
                                collapseAnim.start();
                            } else {
                                expandAnim.start();
                            }
                        }
                        NumberAnimation {
                            id: collapseAnim
                            target: listView
                            property: "implicitHeight"
                            to: 80
                            from: listView.contentHeight
                            duration: 80
                            easing.type: Easing.InOutQuad
                            onStopped: {
                                listView.isExpandedAnim = listView.isExpanded;
                            }
                        }

                        NumberAnimation {
                            id: expandAnim
                            target: listView
                            property: "implicitHeight"
                            from: 80
                            to: listView.contentHeight
                            duration: 80
                            easing.type: Easing.InOutQuad
                            onStopped: {
                                listView.isExpandedAnim = listView.isExpanded;
                            }
                        }

                        Behavior on y {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }

                        displaced: Transition {
                            NumberAnimation {
                                properties: "y,x"
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }

                        delegate: Rectangle {
                            id: notificationItem
                            required property var modelData
                            required property int index
                            width: listView.width
                            height: 80
                            color: "#801a1a1a"
                            border.color: "#555555"
                            border.width: 1
                            radius: 8
                            clip: true
                            visible: true
                            opacity: 1

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    listView.isExpanded ? ( notificationItem.index === 0 ? listView.isExpanded = false : null ) : listView.isExpanded = true;
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                IconImage {
                                    source: notificationItem.modelData.image
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 48
                                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Text {
                                        text: notificationItem.modelData.appName
                                        color: "white"
                                        font.bold: true
                                        font.pointSize: 12
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: notificationItem.modelData.summary
                                        color: "white"
                                        font.pointSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: notificationItem.modelData.body
                                        color: "#dddddd"
                                        font.pointSize: 8
                                        elide: Text.ElideRight
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignVCenter
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
                                        root.notifications[modelData].dismiss();
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
