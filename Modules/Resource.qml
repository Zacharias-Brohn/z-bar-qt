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

	clip: true
	percentage: 0

	Behavior on animatedPercentage {
		Anim {
			duration: Appearance.anim.durations.large
		}
	}

	Component.onCompleted: animatedPercentage = percentage
	onPercentageChanged: animatedPercentage = percentage

	// Canvas {
	// 	id: gaugeCanvas
	//
	// 	anchors.centerIn: parent
	// 	height: width
	// 	width: Math.min(parent.width, parent.height)
	//
	// 	Component.onCompleted: requestPaint()
	// 	onPaint: {
	// 		const ctx = getContext("2d");
	// 		ctx.reset();
	// 		const cx = width / 2;
	// 		const cy = (height / 2) + 1;
	// 		const radius = (Math.min(width, height) - 12) / 2;
	// 		const lineWidth = 3;
	// 		ctx.beginPath();
	// 		ctx.arc(cx, cy, radius, root.arcStartAngle, root.arcStartAngle + root.arcSweep);
	// 		ctx.lineWidth = lineWidth;
	// 		ctx.lineCap = "round";
	// 		ctx.strokeStyle = DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2);
	// 		ctx.stroke();
	// 		if (root.animatedPercentage > 0) {
	// 			ctx.beginPath();
	// 			ctx.arc(cx, cy, radius, root.arcStartAngle, root.arcStartAngle + root.arcSweep * root.animatedPercentage);
	// 			ctx.lineWidth = lineWidth;
	// 			ctx.lineCap = "round";
	// 			ctx.strokeStyle = root.accentColor;
	// 			ctx.stroke();
	// 		}
	// 	}
	//
	// 	Connections {
	// 		function onAnimatedPercentageChanged() {
	// 			gaugeCanvas.requestPaint();
	// 		}
	//
	// 		target: root
	// 	}
	//
	// 	Connections {
	// 		function onPaletteChanged() {
	// 			gaugeCanvas.requestPaint();
	// 		}
	//
	// 		target: DynamicColors
	// 	}
	// }

	MaterialIcon {
		id: icon

		color: DynamicColors.palette.m3onSurface
		font.pointSize: 12
		text: root.icon
	}

	CustomClippingRect {
		Layout.preferredHeight: root.height
		Layout.preferredWidth: 5
		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		radius: Appearance.rounding.full

		CustomRect {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			color: root.mainColor
			implicitHeight: root.percentage * parent.height
			radius: implicitHeight / 2

			Behavior on implicitHeight {
				Anim {
				}
			}
		}
	}
}
