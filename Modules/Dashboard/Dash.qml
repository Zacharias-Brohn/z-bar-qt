import Quickshell
import QtQuick.Layouts
import qs.Helpers
import qs.Components
import qs.Modules
import qs.Config
import qs.Modules.Dashboard.Dash

GridLayout {
    id: root

    required property PersistentProperties state

    rowSpacing: 8
    columnSpacing: 8

    Rect {
        Layout.column: 2
        Layout.columnSpan: 3
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48

        radius: 8

		CachingImage {
			path: Quickshell.env("HOME") + "/.face"
		}
    }

    Rect {
        Layout.row: 0
        Layout.columnSpan: 2
        Layout.preferredWidth: Config.dashboard.sizes.weatherWidth
        Layout.fillHeight: true

        radius: 8

        Weather {}
    }

    Rect {
        Layout.row: 1
        Layout.preferredWidth: dateTime.implicitWidth
        Layout.fillHeight: true

        radius: 8

        DateTime {
            id: dateTime
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.fillWidth: true
        Layout.preferredHeight: 100

        radius: 8

    }

    Rect {
        Layout.row: 1
        Layout.column: 4
        Layout.preferredWidth: 100
        Layout.fillHeight: true

        radius: 8

    }

    Rect {
        Layout.row: 0
        Layout.column: 5
        Layout.rowSpan: 2
        Layout.preferredWidth: 100
        Layout.fillHeight: true

        radius: 8

    }

    component Rect: CustomRect {
        color: DynamicColors.tPalette.m3surfaceContainer
    }
}
