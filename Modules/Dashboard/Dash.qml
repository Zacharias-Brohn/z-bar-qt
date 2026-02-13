import Quickshell
import QtQuick.Layouts
import qs.Helpers
import qs.Components
import qs.Paths
import qs.Modules
import qs.Config
import qs.Modules.Dashboard.Dash

GridLayout {
    id: root

    required property PersistentProperties state

    rowSpacing: Appearance.spacing.normal
    columnSpacing: Appearance.spacing.normal

    Rect {
        Layout.column: 2
        Layout.columnSpan: 3
        Layout.preferredWidth: user.implicitWidth
        Layout.preferredHeight: user.implicitHeight

        radius: 6

        User {
            id: user

            state: root.state
        }
    }

    Rect {
        Layout.row: 0
        Layout.columnSpan: 2
        Layout.preferredWidth: Config.dashboard.sizes.weatherWidth
        Layout.fillHeight: true

        radius: 6

        Weather {}
    }

    Rect {
        Layout.row: 1
        Layout.preferredWidth: dateTime.implicitWidth
        Layout.fillHeight: true

        radius: 6

        DateTime {
            id: dateTime
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.fillWidth: true
        Layout.preferredHeight: calendar.implicitHeight

        radius: 6

        Calendar {
            id: calendar

            state: root.state
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 4
        Layout.preferredWidth: resources.implicitWidth
        Layout.fillHeight: true

        radius: 6

        Resources {
            id: resources
        }
    }

    Rect {
        Layout.row: 0
        Layout.column: 5
        Layout.rowSpan: 2
        Layout.preferredWidth: media.implicitWidth
        Layout.fillHeight: true

        radius: 6

        Media {
            id: media
        }
    }

    component Rect: CustomRect {
        color: DynamicColors.tPalette.m3surfaceContainer
    }
}
