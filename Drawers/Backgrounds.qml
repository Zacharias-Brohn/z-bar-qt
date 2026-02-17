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

Shape {
    id: root

    required property Panels panels
    required property Item bar
	required property PersistentProperties visibilities

    anchors.fill: parent
    // anchors.margins: 8
    anchors.topMargin: bar.implicitHeight
    preferredRendererType: Shape.CurveRenderer

	Component.onCompleted: console.log(root.bar.implicitHeight, root.bar.anchors.topMargin)

	Osd.Background {
		wrapper: root.panels.osd

		startX: root.width - root.panels.sidebar.width
		startY: ( root.height - wrapper.height ) / 2 - rounding
	}

    Modules.Background {
        wrapper: root.panels.popouts
        invertBottomRounding: wrapper.x <= 0

        startX: wrapper.x - 8
        startY: wrapper.y
    }

	Notifications.Background {
		wrapper: root.panels.notifications
		sidebar: sidebar

		startX: root.width
		startY: 0
	}

	Launcher.Background {
		wrapper: root.panels.launcher

		startX: ( root.width - wrapper.width ) / 2 - rounding
		startY: root.height
	}

	Dashboard.Background {
		wrapper: root.panels.dashboard

		startX: root.width - root.panels.dashboard.width - rounding
		startY: 0
	}

	Utils.Background {
		wrapper: root.panels.utilities
		sidebar: sidebar

		startX: root.width
		startY: root.height
	}

	Sidebar.Background {
		id: sidebar

		wrapper: root.panels.sidebar
		panels: root.panels

		startX: root.width
		startY: root.panels.notifications.height
	}
}
