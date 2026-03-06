import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Components
import qs.Config

Item {
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
	height: implicitHeight
	implicitHeight: 34
	implicitWidth: 34
	percentage: 0
	visible: width > 0 && height > 0
	width: implicitWidth

	Behavior on animatedPercentage {
		Anim {
			duration: Appearance.anim.durations.large
		}
	}

	Component.onCompleted: animatedPercentage = percentage
	onPercentageChanged: animatedPercentage = percentage

	Canvas {
		id: gaugeCanvas

		anchors.centerIn: parent
		height: width
		width: Math.min(parent.width, parent.height)

		Component.onCompleted: requestPaint()
		onPaint: {
			const ctx = getContext("2d");
			ctx.reset();
			const cx = width / 2;
			const cy = (height / 2) + 1;
			const radius = (Math.min(width, height) - 12) / 2;
			const lineWidth = 3;
			ctx.beginPath();
			ctx.arc(cx, cy, radius, root.arcStartAngle, root.arcStartAngle + root.arcSweep);
			ctx.lineWidth = lineWidth;
			ctx.lineCap = "round";
			ctx.strokeStyle = DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2);
			ctx.stroke();
			if (root.animatedPercentage > 0) {
				ctx.beginPath();
				ctx.arc(cx, cy, radius, root.arcStartAngle, root.arcStartAngle + root.arcSweep * root.animatedPercentage);
				ctx.lineWidth = lineWidth;
				ctx.lineCap = "round";
				ctx.strokeStyle = root.accentColor;
				ctx.stroke();
			}
		}

		Connections {
			function onAnimatedPercentageChanged() {
				gaugeCanvas.requestPaint();
			}

			target: root
		}

		Connections {
			function onPaletteChanged() {
				gaugeCanvas.requestPaint();
			}

			target: DynamicColors
		}
	}

	MaterialIcon {
		anchors.centerIn: parent
		color: DynamicColors.palette.m3onSurface
		font.pointSize: 12
		text: root.icon
	}
}
