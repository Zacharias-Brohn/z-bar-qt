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

	readonly property bool dashboardVisible: visibilities.dashboard
	property int radius: 6
	required property PersistentProperties state
	required property PersistentProperties visibilities

	columnSpacing: Appearance.spacing.smaller
	opacity: 0
	rowSpacing: Appearance.spacing.smaller
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
			property: "opacity"
			target: root
			to: 1
		}

		Anim {
			property: "scale"
			target: root
			to: 1
		}
	}

	ParallelAnimation {
		id: closeAnim

		Anim {
			property: "opacity"
			target: root
			to: 0
		}

		Anim {
			property: "scale"
			target: root
			to: 0.9
		}
	}

	Rect {
		Layout.column: 2
		Layout.columnSpan: 3
		Layout.preferredHeight: user.implicitHeight
		Layout.preferredWidth: user.implicitWidth
		radius: root.radius

		User {
			id: user

			state: root.state
		}
	}

	Rect {
		Layout.columnSpan: 2
		Layout.fillHeight: true
		Layout.preferredWidth: Config.dashboard.sizes.weatherWidth
		Layout.row: 0
		radius: root.radius

		Weather {
		}
	}

	// Rect {
	//     Layout.row: 1
	//     Layout.preferredWidth: dateTime.implicitWidth
	//     Layout.fillHeight: true
	//
	//     radius: root.radius
	//
	//     DateTime {
	//         id: dateTime
	//     }
	// }

	Rect {
		Layout.column: 0
		Layout.columnSpan: 3
		Layout.fillWidth: true
		Layout.preferredHeight: calendar.implicitHeight
		Layout.row: 1
		radius: root.radius

		Calendar {
			id: calendar

			state: root.state
		}
	}

	Rect {
		Layout.column: 3
		Layout.columnSpan: 2
		Layout.fillHeight: true
		Layout.preferredWidth: resources.implicitWidth
		Layout.row: 1
		radius: root.radius

		Resources {
			id: resources

		}
	}

	Rect {
		Layout.column: 5
		Layout.fillHeight: true
		Layout.preferredWidth: media.implicitWidth
		Layout.row: 0
		Layout.rowSpan: 2
		radius: root.radius

		Media {
			id: media

		}
	}

	component Rect: CustomRect {
		color: DynamicColors.tPalette.m3surfaceContainer
	}
}
