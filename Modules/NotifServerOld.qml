pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs.Modules

Scope {
    id: root
    property list<int> notifIds: []
    property list<TrackedNotification> notifications;
    // NotificationServer {
    //     id: notificationServer
    //     imageSupported: true
    //     actionsSupported: true
    //     persistenceSupported: true
    //     bodyImagesSupported: true
    //     bodySupported: true
    //     onNotification: notification => {
    //         notification.tracked = true;
    //         notification.receivedTime = Date.now();
    //         root.notifIds.push(notification.id);
    //         const notif = notificationComponent.createObject(root, { notif: notification, visible: !notificationCenter.doNotDisturb });
    //         root.notifications.push(notif);
    //     }
    // }

    Connections {
        target: NotifServer.server
        function onNotification() {
            notificationComponent.createObject( root, { notif: NotifServer.list[0] });
        }
    }

    Component {
        id: notificationComponent
        TrackedNotification {
            centerX: notificationCenter.posX
            notifIndex: root.notifIds
            notifList: root.notifications
            onNotifDestroy: {
                root.notifications.shift();
                root.notifIds.shift();
            }
        }
    }

    NotificationCenter {
        id: notificationCenter
        notifications: notificationServer.trackedNotifications.values
    }
}
