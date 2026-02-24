import Quickshell
import QtQuick
import qs.Components
import qs.Modules as Modules
import qs.Modules.Notifications as Notifications
import qs.Modules.Notifications.Sidebar as Sidebar
import qs.Modules.Notifications.Sidebar.Utils as Utils
import qs.Modules.Dashboard as Dashboard
import qs.Modules.Osd as Osd
import qs.Components.Toast as Toasts
import qs.Modules.Launcher as Launcher
import qs.Modules.Settings as Settings
import qs.Config

Item {
	id: root

	required property Item bar
	readonly property alias dashboard: dashboard
	readonly property alias launcher: launcher
	readonly property alias notifications: notifications
	readonly property alias osd: osd
	readonly property alias popouts: popouts
	required property ShellScreen screen
	readonly property alias settings: settings
	readonly property alias sidebar: sidebar
	readonly property alias toasts: toasts
	readonly property alias utilities: utilities
	required property PersistentProperties visibilities

	anchors.fill: parent
	// anchors.margins: 8
	anchors.topMargin: Config.barConfig.autoHide && !visibilities.bar ? 0 : bar.implicitHeight

	Behavior on anchors.topMargin {
		Anim {
		}
	}

	Osd.Wrapper {
		id: osd

		anchors.right: parent.right
		anchors.rightMargin: sidebar.width
		anchors.verticalCenter: parent.verticalCenter
		clip: sidebar.width > 0
		screen: root.screen
		visibilities: root.visibilities
	}

	Modules.Wrapper {
		id: popouts

		anchors.top: parent.top
		screen: root.screen
		x: {
			const off = currentCenter - nonAnimWidth / 2;
			const diff = root.width - Math.floor(off + nonAnimWidth);
			if (diff < 0)
				return off + diff;
			return Math.floor(Math.max(off, 0));
		}
	}

	Toasts.Toasts {
		id: toasts

		anchors.bottom: sidebar.visible ? parent.bottom : utilities.top
		anchors.margins: Appearance.padding.normal
		anchors.right: sidebar.left
	}

	Notifications.Wrapper {
		id: notifications

		anchors.right: parent.right
		anchors.top: parent.top
		panels: root
		visibilities: root.visibilities
	}

	Launcher.Wrapper {
		id: launcher

		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		panels: root
		screen: root.screen
		visibilities: root.visibilities
	}

	Utils.Wrapper {
		id: utilities

		anchors.bottom: parent.bottom
		anchors.right: parent.right
		popouts: popouts
		sidebar: sidebar
		visibilities: root.visibilities
	}

	Dashboard.Wrapper {
		id: dashboard

		anchors.right: parent.right
		anchors.top: parent.top
		visibilities: root.visibilities
	}

	Sidebar.Wrapper {
		id: sidebar

		anchors.bottom: utilities.top
		anchors.right: parent.right
		anchors.top: notifications.bottom
		panels: root
		visibilities: root.visibilities
	}

	Settings.Wrapper {
		id: settings

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		panels: root
		visibilities: root.visibilities
	}
}
