pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    id: root
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
            notificationCenter.groupedData.addNotification(notification);
            notificationComponent.createObject(root, { notif: notification, visible: !notificationCenter.doNotDisturb });
        }
    }

    Component {
        id: notificationComponent
        Notif {
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
