import Quickshell
import QtQuick
import QtQuick.Shapes
import qs.Modules as Modules
import qs.Modules.Notifications as Notifications
import qs.Modules.Notifications.Sidebar as Sidebar
import qs.Modules.Notifications.Sidebar.Utils as Utils
import qs.Modules.Dashboard as Dashboard
import qs.Modules.Osd as Osd
import qs.Components.Toast as Toasts
import qs.Config

Item {
    id: root

    required property ShellScreen screen
    required property Item bar
	required property PersistentProperties visibilities

    readonly property alias popouts: popouts
	readonly property alias sidebar: sidebar
	readonly property alias notifications: notifications
	readonly property alias utilities: utilities
	readonly property alias dashboard: dashboard
	readonly property alias osd: osd
	readonly property alias toasts: toasts

    anchors.fill: parent
    // anchors.margins: 8
    anchors.topMargin: bar.implicitHeight

	Osd.Wrapper {
		id: osd

		clip: sidebar.width > 0
		screen: root.screen
		visibilities: root.visibilities

		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: sidebar.width
	}

    Modules.Wrapper {
        id: popouts

        screen: root.screen

        anchors.top: parent.top

        x: {
            const off = currentCenter - nonAnimWidth / 2;
            const diff = root.width - Math.floor(off + nonAnimWidth);
            if ( diff < 0 )
                return off + diff;
            return Math.floor( Math.max( off, 0 ));
        }
    }

	Toasts.Toasts {
		id: toasts

		anchors.bottom: sidebar.visible ? parent.bottom : utilities.top
		anchors.right: sidebar.left
		anchors.margins: Appearance.padding.normal
	}

	Notifications.Wrapper {
		id: notifications

		visibilities: root.visibilities
		panels: root

		anchors.top: parent.top
		anchors.right: parent.right
	}

	Utils.Wrapper {
		id: utilities

		visibilities: root.visibilities
		sidebar: sidebar
		popouts: popouts

		anchors.bottom: parent.bottom
		anchors.right: parent.right
	}

	Dashboard.Wrapper {
		id: dashboard

		visibilities: root.visibilities

		anchors.right: parent.right
		anchors.top: parent.top
	}

	Sidebar.Wrapper {
		id: sidebar

		visibilities: root.visibilities
		panels: root

		anchors.top: notifications.bottom
		anchors.bottom: utilities.top
		anchors.right: parent.right
	}
}
