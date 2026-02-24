import Quickshell
import QtQuick
import QtQuick.Shapes
import qs.Modules as Modules
import qs.Modules.Notifications as Notifications
import qs.Modules.Notifications.Sidebar as Sidebar
import qs.Modules.Notifications.Sidebar.Utils as Utils
import qs.Modules.Dashboard as Dashboard
import qs.Modules.Osd as Osd
import qs.Modules.Launcher as Launcher
import qs.Modules.Settings as Settings

Shape {
	id: root

	required property Item bar
	required property Panels panels
	required property PersistentProperties visibilities

	anchors.fill: parent
	// anchors.margins: 8
	anchors.topMargin: bar.implicitHeight
	preferredRendererType: Shape.CurveRenderer

	Component.onCompleted: console.log(root.bar.implicitHeight, root.bar.anchors.topMargin)

	Osd.Background {
		startX: root.width - root.panels.sidebar.width
		startY: (root.height - wrapper.height) / 2 - rounding
		wrapper: root.panels.osd
	}

	Modules.Background {
		invertBottomRounding: wrapper.x <= 0
		startX: wrapper.x - 8
		startY: wrapper.y
		wrapper: root.panels.popouts
	}

	Notifications.Background {
		sidebar: sidebar
		startX: root.width
		startY: 0
		wrapper: root.panels.notifications
	}

	Launcher.Background {
		startX: (root.width - wrapper.width) / 2 - rounding
		startY: root.height
		wrapper: root.panels.launcher
	}

	Dashboard.Background {
		startX: root.width - root.panels.dashboard.width - rounding
		startY: 0
		wrapper: root.panels.dashboard
	}

	Utils.Background {
		sidebar: sidebar
		startX: root.width
		startY: root.height
		wrapper: root.panels.utilities
	}

	Sidebar.Background {
		id: sidebar

		panels: root.panels
		startX: root.width
		startY: root.panels.notifications.height
		wrapper: root.panels.sidebar
	}

	Settings.Background {
		id: settings

		startX: (root.width - wrapper.width) / 2 - rounding
		startY: 0
		wrapper: root.panels.settings
	}
}
