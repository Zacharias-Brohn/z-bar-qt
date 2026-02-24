import QtQuick
import qs.Components
import qs.Helpers
import qs.Config

Row {
	id: root

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	padding: Appearance.padding.large
	spacing: Appearance.spacing.large

	Ref {
		service: SystemUsage
	}

	Resource {
		color: DynamicColors.palette.m3primary
		icon: "memory"
		value: SystemUsage.cpuPerc
	}

	Resource {
		color: DynamicColors.palette.m3secondary
		icon: "memory_alt"
		value: SystemUsage.memPerc
	}

	Resource {
		color: DynamicColors.palette.m3tertiary
		icon: "gamepad"
		value: SystemUsage.gpuPerc
	}

	Resource {
		color: DynamicColors.palette.m3primary
		icon: "host"
		value: SystemUsage.gpuMemUsed
	}

	Resource {
		color: DynamicColors.palette.m3secondary
		icon: "hard_disk"
		value: SystemUsage.storagePerc
	}

	component Resource: Item {
		id: res

		required property color color
		required property string icon
		required property real value

		anchors.bottom: parent.bottom
		anchors.margins: Appearance.padding.large
		anchors.top: parent.top
		implicitWidth: icon.implicitWidth

		Behavior on value {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		CustomRect {
			anchors.bottom: icon.top
			anchors.bottomMargin: Appearance.spacing.small
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: parent.top
			color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
			implicitWidth: Config.dashboard.sizes.resourceProgessThickness
			radius: Appearance.rounding.full

			CustomRect {
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				color: res.color
				implicitHeight: res.value * parent.height
				radius: Appearance.rounding.full
			}
		}

		MaterialIcon {
			id: icon

			anchors.bottom: parent.bottom
			color: res.color
			text: res.icon
		}
	}
}
