pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.Helpers
import qs.Modules
import qs.Config
import qs.Components

CustomRect {
	id: root

	required property PersistentProperties visibilities

	clip: true
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: Config.barConfig.height + Appearance.padding.smallest * 2
	implicitWidth: rowLayout.implicitWidth + Appearance.padding.normal * 2
	radius: height / 2

	StateLayer {
		onClicked: root.visibilities.resources = !root.visibilities.resources
	}

	RowLayout {
		id: rowLayout

		anchors.centerIn: parent
		implicitHeight: root.implicitHeight
		spacing: Appearance.spacing.smaller

		Ref {
			service: SystemUsage
		}

		Resource {
			Layout.alignment: Qt.AlignVCenter
			Layout.fillHeight: true
			icon: "memory"
			mainColor: DynamicColors.palette.m3primary
			percentage: SystemUsage.cpuPerc
			warningThreshold: 95
		}

		Resource {
			Layout.fillHeight: true
			icon: "memory_alt"
			mainColor: DynamicColors.palette.m3secondary
			percentage: SystemUsage.memPerc
			warningThreshold: 80
		}

		Resource {
			Layout.fillHeight: true
			icon: "gamepad"
			mainColor: DynamicColors.palette.m3tertiary
			percentage: SystemUsage.gpuPerc
		}

		Resource {
			Layout.fillHeight: true
			icon: "developer_board"
			mainColor: DynamicColors.palette.m3primary
			percentage: SystemUsage.gpuMemUsed
		}
	}
}
