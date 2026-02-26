pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import qs.Modules
import qs.Config
import qs.Effects
import qs.Components

Item {
	id: root

	clip: true
	implicitHeight: 34
	implicitWidth: rowLayout.implicitWidth + Appearance.padding.small * 2

	CustomRect {
		id: backgroundRect

		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 22
		radius: height / 2

		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
		}
	}

	RowLayout {
		id: rowLayout

		anchors.centerIn: parent
		spacing: 6

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3onSurface
			font.pointSize: 14
			text: "memory_alt"
		}

		Resource {
			Layout.alignment: Qt.AlignVCenter
			mainColor: DynamicColors.palette.m3primary
			percentage: ResourceUsage.memoryUsedPercentage
			warningThreshold: 95
		}

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3onSurface
			font.pointSize: 14
			text: "memory"
		}

		Resource {
			mainColor: DynamicColors.palette.m3secondary
			percentage: ResourceUsage.cpuUsage
			warningThreshold: 80
		}

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3onSurface
			font.pointSize: 14
			text: "gamepad"
		}

		Resource {
			mainColor: DynamicColors.palette.m3tertiary
			percentage: ResourceUsage.gpuUsage
		}

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3onSurface
			font.pointSize: 14
			text: "developer_board"
		}

		Resource {
			mainColor: DynamicColors.palette.m3primary
			percentage: ResourceUsage.gpuMemUsage
		}
	}
}
