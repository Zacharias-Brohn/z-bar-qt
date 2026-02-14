import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Helpers
import qs.Components
import qs.Paths
import qs.Modules
import qs.Config
import qs.Modules.Dashboard.Dash

GridLayout {
    id: root

	required property PersistentProperties visibilities
    required property PersistentProperties state
	readonly property bool dashboardVisible: visibilities.dashboard

    rowSpacing: Appearance.spacing.normal
    columnSpacing: Appearance.spacing.normal

	opacity: 0
	scale: 0.9

	onDashboardVisibleChanged: {
		if (dashboardVisible) {
			openAnim.start();
		} else {
			closeAnim.start();
		}
	}

	ParallelAnimation {
		id: openAnim
		Anim {
			target: root
			property: "opacity"
			to: 1
		}
		Anim {
			target: root
			property: "scale"
			to: 1
		}
	}

	ParallelAnimation {
		id: closeAnim
		Anim {
			target: root
			property: "opacity"
			to: 0
		}
		Anim {
			target: root
			property: "scale"
			to: 0.9
		}
	}

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
