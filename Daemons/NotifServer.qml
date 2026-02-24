pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import QtQuick
import ZShell
import qs.Components
import qs.Modules
import qs.Helpers
import qs.Paths
import qs.Config

Singleton {
	id: root

	property alias dnd: props.dnd
	property list<Notif> list: []
	property bool loaded
	readonly property list<Notif> notClosed: list.filter(n => !n.closed)
	readonly property list<Notif> popups: list.filter(n => n.popup)
	property alias server: server

	onListChanged: {
		if (loaded) {
			saveTimer.restart();
		}
		if (root.list.length > 0) {
			HasNotifications.hasNotifications = true;
		} else {
			HasNotifications.hasNotifications = false;
		}
	}

	Timer {
		id: saveTimer

		interval: 1000

		onTriggered: storage.setText(JSON.stringify(root.notClosed.map(n => ({
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
				}))))
	}

	PersistentProperties {
		id: props

		property bool dnd

		reloadableId: "notifs"
	}

	NotificationServer {
		id: server

		actionsSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		imageSupported: true
		keepOnReload: false
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

		path: `${Paths.state}/notifs.json`

		onLoadFailed: err => {
			if (err === FileViewError.FileNotFound) {
				root.loaded = true;
				setText("[]");
			}
		}
		onLoaded: {
			const data = JSON.parse(text());
			for (const notif of data)
				root.list.push(notifComp.createObject(root, notif));
			root.list.sort((a, b) => b.time - a.time);
			root.loaded = true;
		}
	}

	CustomShortcut {
		description: "Clear all notifications"
		name: "clearnotifs"

		onPressed: {
			for (const notif of root.list.slice())
				notif.close();
		}
	}

	IpcHandler {
		function clear(): void {
			for (const notif of root.list.slice())
				notif.close();
		}

		function disableDnd(): void {
			props.dnd = false;
		}

		function enableDnd(): void {
			props.dnd = true;
		}

		function isDndEnabled(): bool {
			return props.dnd;
		}

		function toggleDnd(): void {
			props.dnd = !props.dnd;
		}

		target: "notifs"
	}

	Component {
		id: notifComp

		Notif {
		}
	}

	component Notif: QtObject {
		id: notif

		property list<var> actions
		property string appIcon
		property string appName
		property string body
		property bool closed
		readonly property Connections conn: Connections {
			function onActionsChanged(): void {
				notif.actions = notif.notification.actions.map(a => ({
							identifier: a.identifier,
							text: a.text,
							invoke: () => a.invoke()
						}));
			}

			function onAppIconChanged(): void {
				notif.appIcon = notif.notification.appIcon;
			}

			function onAppNameChanged(): void {
				notif.appName = notif.notification.appName;
			}

			function onBodyChanged(): void {
				notif.body = notif.notification.body;
			}

			function onClosed(): void {
				notif.close();
			}

			function onExpireTimeoutChanged(): void {
				notif.expireTimeout = notif.notification.expireTimeout;
			}

			function onHasActionIconsChanged(): void {
				notif.hasActionIcons = notif.notification.hasActionIcons;
			}

			function onImageChanged(): void {
				notif.image = notif.notification.image;
				if (notif.notification?.image)
					notif.dummyImageLoader.active = true;
			}

			function onResidentChanged(): void {
				notif.resident = notif.notification.resident;
			}

			function onSummaryChanged(): void {
				notif.summary = notif.notification.summary;
			}

			function onUrgencyChanged(): void {
				notif.urgency = notif.notification.urgency;
			}

			target: notif.notification
		}
		readonly property LazyLoader dummyImageLoader: LazyLoader {
			active: false

			PanelWindow {
				color: "transparent"
				implicitHeight: Config.notifs.sizes.image
				implicitWidth: Config.notifs.sizes.image

				mask: Region {
				}

				Image {
					function tryCache(): void {
						if (status !== Image.Ready || width != Config.notifs.sizes.image || height != Config.notifs.sizes.image)
							return;

						const cacheKey = notif.appName + notif.summary + notif.id;
						let h1 = 0xdeadbeef, h2 = 0x41c6ce57, ch;
						for (let i = 0; i < cacheKey.length; i++) {
							ch = cacheKey.charCodeAt(i);
							h1 = Math.imul(h1 ^ ch, 2654435761);
							h2 = Math.imul(h2 ^ ch, 1597334677);
						}
						h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507);
						h1 ^= Math.imul(h2 ^ (h2 >>> 13), 3266489909);
						h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507);
						h2 ^= Math.imul(h1 ^ (h1 >>> 13), 3266489909);
						const hash = (h2 >>> 0).toString(16).padStart(8, 0) + (h1 >>> 0).toString(16).padStart(8, 0);

						const cache = `${Paths.notifimagecache}/${hash}.png`;
						ZShellIo.saveItem(this, Qt.resolvedUrl(cache), () => {
							notif.image = cache;
							notif.dummyImageLoader.active = false;
						});
					}

					anchors.fill: parent
					asynchronous: true
					cache: false
					fillMode: Image.PreserveAspectCrop
					opacity: 0
					source: Qt.resolvedUrl(notif.image)

					onHeightChanged: tryCache()
					onStatusChanged: tryCache()
					onWidthChanged: tryCache()
				}
			}
		}
		property real expireTimeout: 5
		property bool hasActionIcons
		property string id
		property string image
		property var locks: new Set()
		property Notification notification
		property bool popup
		property bool resident
		property string summary
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
		readonly property Timer timer: Timer {
			property bool paused: false
			property int remainingTime: totalTime
			property int totalTime: Config.notifs.defaultExpireTimeout

			interval: 50
			repeat: true
			running: !paused

			onTriggered: {
				remainingTime -= interval;

				if (remainingTime <= 0) {
					remainingTime = 0;
					notif.popup = false;
					stop();
				}
			}
		}
		property int urgency: NotificationUrgency.Normal

		function close(): void {
			closed = true;
			if (locks.size === 0 && root.list.includes(this)) {
				root.list = root.list.filter(n => n !== this);
				notification?.dismiss();
				destroy();
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

		Component.onCompleted: {
			if (!notification)
				return;

			id = notification.id;
			summary = notification.summary;
			body = notification.body;
			appIcon = notification.appIcon;
			appName = notification.appName;
			image = notification.image;
			if (notification?.image)
				dummyImageLoader.active = true;
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
}
