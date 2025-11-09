pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs.Modules

Rectangle {
    id: root

    Text {
        text: "\ue7f4"
        font.family: "Material Symbols Rounded"
        font.pixelSize: 16
        color: "white"
        anchors.centerIn: parent
    }

    property list<int> notifIds: []
    NotificationServer {
        id: notificationServer
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true
        bodyImagesSupported: true
        bodySupported: true
        onNotification: {
            notification.tracked = true;
            notification.receivedTime = Date.now();
            root.notifIds.push(notification.id);
            notificationComponent.createObject(root, { notif: notification, visible: !notificationCenter.doNotDisturb });
        }
    }

    Component {
        id: notificationComponent
        Notification {
            centerX: notificationCenter.posX
            notifIndex: root.notifIds
            onNotifDestroy: {
                root.notifIds.shift();
            }
        }
    }

    NotificationCenter {
        id: notificationCenter
        notifications: notificationServer.trackedNotifications.values
    }
}
