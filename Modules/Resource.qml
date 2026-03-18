import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Components
import qs.Config

RowLayout {
	id: root

	property color accentColor: warning ? DynamicColors.palette.m3error : mainColor
	property real animatedPercentage: 0
	readonly property real arcStartAngle: 0.75 * Math.PI
	readonly property real arcSweep: 1.5 * Math.PI
	property string icon
	required property color mainColor
	required property double percentage
	property bool shown: true
	property color usageColor: warning ? DynamicColors.palette.m3error : mainColor
	property bool warning: percentage * 100 >= warningThreshold
	property int warningThreshold: 80

	percentage: 0

	Behavior on animatedPercentage {
		Anim {
		}
	}

	Component.onCompleted: animatedPercentage = percentage
	onPercentageChanged: {
		const next = percentage;

		if (Math.abs(next - animatedPercentage) >= 0.05)
			animatedPercentage = next;
	}

	MaterialIcon {
		id: icon

		color: DynamicColors.palette.m3onSurface
		font.pointSize: Appearance.font.size.larger
		text: root.icon
	}

	CustomClippingRect {
		Layout.preferredHeight: root.height - Appearance.padding.small
		Layout.preferredWidth: 4
		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		radius: Appearance.rounding.full

		CustomRect {
			id: fill

			anchors.fill: parent
			antialiasing: false
			color: root.mainColor
			implicitHeight: Math.ceil(root.percentage * parent.height)
			radius: Appearance.rounding.full

			transform: Scale {
				origin.y: fill.height
				yScale: Math.max(0.001, root.animatedPercentage)
			}
		}
	}
}
