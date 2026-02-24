import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

GridLayout {
	id: root

	anchors.left: parent.left
	anchors.margins: Appearance.padding.large
	anchors.right: parent.right
	columnSpacing: Appearance.spacing.large
	columns: 2
	rowSpacing: Appearance.spacing.large
	rows: 1

	Ref {
		service: SystemUsage
	}

	Resource {
		Layout.bottomMargin: Appearance.padding.large
		Layout.topMargin: Appearance.padding.large
		colour: DynamicColors.palette.m3primary
		icon: "memory"
		value: SystemUsage.cpuPerc
	}

	Resource {
		Layout.bottomMargin: Appearance.padding.large
		Layout.topMargin: Appearance.padding.large
		colour: DynamicColors.palette.m3secondary
		icon: "memory_alt"
		value: SystemUsage.memPerc
	}

	component Resource: CustomRect {
		id: res

		required property color colour
		required property string icon
		required property real value

		Layout.fillWidth: true
		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		implicitHeight: width
		radius: Appearance.rounding.large

		Behavior on value {
			Anim {
				duration: Appearance.anim.durations.large
			}
		}

		CircularProgress {
			id: circ

			anchors.fill: parent
			bgColour: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 3)
			fgColour: res.colour
			padding: Appearance.padding.large * 3
			strokeWidth: width < 200 ? Appearance.padding.smaller : Appearance.padding.normal
			value: res.value
		}

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			color: res.colour
			font.pointSize: (circ.arcRadius * 0.7) || 1
			font.weight: 600
			text: res.icon
		}
	}
}
