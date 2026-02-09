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
        Layout.preferredWidth: 250
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

    component Rect: CustomRect {
        color: DynamicColors.tPalette.m3surfaceContainer
    }
}
