pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import qs.Modules
import qs.Helpers

Singleton {
    id: root

    property list<Notif> list: []
    readonly property list<Notif> notClosed: list.filter( n => !n.closed )
    readonly property list<Notif> popups: list.filter( n => n.popup )
    property alias dnd: props.dnd
    property alias server: server

    property bool loaded

    onListChanged: {
        if ( loaded ) {
            saveTimer.restart();
        }
        if ( root.list.length > 0 ) {
            HasNotifications.hasNotifications = true;
        } else {
            HasNotifications.hasNotifications = false;
        }
    }

    Timer {
        id: saveTimer
        interval: 1000
        onTriggered: storage.setText( JSON.stringify( root.notClosed.map( n => ({
                    time: n.time,
                    id: n.id,
                    summary: n.summary,
                    body: n.body,
                    appIcon: n.appIcon,
                    appName: n.appName,
                    image: n.image,
                    expireTimeout: n.expireTimeout,
                    urgency: n.urgency,
                    resident: n.resident,
                    hasActionIcons: n.hasActionIcons,
                    actions: n.actions
                }))));
    }

    PersistentProperties {
        id: props

        property bool dnd

        reloadableId: "notifs"
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;

            const comp = notifComp.createObject(root, {
                popup: !props.dnd,
                notification: notif
            });
            root.list = [comp, ...root.list];
        }
    }

    FileView {
        id: storage
        path: NotifPath.notifPath

        onLoaded: {
            const data = JSON.parse(text());
            for (const notif of data)
                root.list.push(notifComp.createObject(root, notif));
            root.list.sort((a, b) => b.time - a.time);
            root.loaded = true;
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.loaded = true;
                setText("[]");
            }
        }
    }

    component Notif: QtObject {
        id: notif

        property bool popup
        property bool closed
        property var locks: new Set()

        property date time: new Date()
        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);

            if (m < 1)
                return qsTr("now");

            const h = Math.floor(m / 60);
            const d = Math.floor(h / 24);

            if (d > 0)
                return `${d}d`;
            if (h > 0)
                return `${h}h`;
            return `${m}m`;
        }

        property Notification notification
        property string id
        property string summary
        property string body
        property string appIcon
        property string appName
        property string image
        property real expireTimeout: 5
        property int urgency: NotificationUrgency.Normal
        property bool resident
        property bool hasActionIcons
        property list<var> actions

        readonly property Timer timer: Timer {
            running: true
            interval: 5000
            onTriggered: {
                notif.popup = false;
            }
        }

        readonly property Connections conn: Connections {
            target: notif.notification

            function onClosed(): void {
                notif.close();
            }

            function onSummaryChanged(): void {
                notif.summary = notif.notification.summary;
            }

            function onBodyChanged(): void {
                notif.body = notif.notification.body;
            }

            function onAppIconChanged(): void {
                notif.appIcon = notif.notification.appIcon;
            }

            function onAppNameChanged(): void {
                notif.appName = notif.notification.appName;
            }

            function onImageChanged(): void {
                notif.image = notif.notification.image;
            }

            function onExpireTimeoutChanged(): void {
                notif.expireTimeout = notif.notification.expireTimeout;
            }

            function onUrgencyChanged(): void {
                notif.urgency = notif.notification.urgency;
            }

            function onResidentChanged(): void {
                notif.resident = notif.notification.resident;
            }

            function onHasActionIconsChanged(): void {
                notif.hasActionIcons = notif.notification.hasActionIcons;
            }

            function onActionsChanged(): void {
                notif.actions = notif.notification.actions.map(a => ({
                            identifier: a.identifier,
                            text: a.text,
                            invoke: () => a.invoke()
                        }));
            }
        }

        function lock(item: Item): void {
            locks.add(item);
        }

        function unlock(item: Item): void {
            locks.delete(item);
            if (closed)
                close();
        }

        function close(): void {
            closed = true;
            if (locks.size === 0 && root.list.includes(this)) {
                root.list = root.list.filter(n => n !== this);
                notification?.dismiss();
                destroy();
            }
        }

        Component.onCompleted: {
            if (!notification)
                return;

            id = notification.id;
            summary = notification.summary;
            body = notification.body;
            appIcon = notification.appIcon;
            appName = notification.appName;
            image = notification.image;
            expireTimeout = notification.expireTimeout;
            urgency = notification.urgency;
            resident = notification.resident;
            hasActionIcons = notification.hasActionIcons;
            actions = notification.actions.map(a => ({
                        identifier: a.identifier,
                        text: a.text,
                        invoke: () => a.invoke()
                    }));
        }
    }

    Component {
        id: notificationPopup
        TrackedNotification {
            centerX: NotificationCenter.posX
        }
    }

    Component {
        id: notifComp

        Notif {}
    }
}
