pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Item {
	id: root

	readonly property real arcStartAngle: 0.75 * Math.PI
	readonly property real arcSweep: 1.5 * Math.PI
	property real currentHue: 0
	property bool dragActive: false
	required property var drawing
	readonly property real handleAngle: hueToAngle(currentHue)
	readonly property real handleCenterX: width / 2 + radius * Math.cos(handleAngle)
	readonly property real handleCenterY: height / 2 + radius * Math.sin(handleAngle)
	property real handleSize: 32
	property real lastChromaticHue: 0
	readonly property real radius: (Math.min(width, height) - handleSize) / 2
	readonly property int segmentCount: 240
	readonly property color thumbColor: DynamicColors.palette.m3inverseSurface
	readonly property color thumbContentColor: DynamicColors.palette.m3inverseOnSurface
	readonly property color trackColor: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)

	function hueToAngle(hue) {
		return arcStartAngle + arcSweep * hue;
	}

	function normalizeAngle(angle) {
		const tau = Math.PI * 2;
		let a = angle % tau;
		if (a < 0)
			a += tau;
		return a;
	}

	function pointIsOnTrack(x, y) {
		const cx = width / 2;
		const cy = height / 2;
		const dx = x - cx;
		const dy = y - cy;
		const distance = Math.sqrt(dx * dx + dy * dy);

		return distance >= radius - handleSize / 2 && distance <= radius + handleSize / 2;
	}

	function syncFromPenColor() {
		if (!drawing)
			return;

		const c = drawing.penColor;

		if (c.hsvSaturation > 0) {
			currentHue = c.hsvHue;
			lastChromaticHue = c.hsvHue;
		} else {
			currentHue = lastChromaticHue;
		}

		canvas.requestPaint();
	}

	function updateHueFromPoint(x, y, force = false) {
		const cx = width / 2;
		const cy = height / 2;
		const dx = x - cx;
		const dy = y - cy;

		const distance = Math.sqrt(dx * dx + dy * dy);

		if (!force && (distance < radius - handleSize / 2 || distance > radius + handleSize / 2))
			return;

		const angle = normalizeAngle(Math.atan2(dy, dx));
		const start = normalizeAngle(arcStartAngle);

		let relative = angle - start;
		if (relative < 0)
			relative += Math.PI * 2;

		if (relative > arcSweep) {
			const gap = Math.PI * 2 - arcSweep;
			relative = relative < arcSweep + gap / 2 ? arcSweep : 0;
		}

		currentHue = relative / arcSweep;
		lastChromaticHue = currentHue;
		drawing.penColor = Qt.hsva(currentHue, drawing.penColor.hsvSaturation, drawing.penColor.hsvValue, drawing.penColor.a);
	}

	implicitHeight: 180
	implicitWidth: 220

	Component.onCompleted: syncFromPenColor()
	onCurrentHueChanged: canvas.requestPaint()
	onDrawingChanged: syncFromPenColor()
	onHandleSizeChanged: canvas.requestPaint()
	onHeightChanged: canvas.requestPaint()
	onWidthChanged: canvas.requestPaint()

	Connections {
		function onPenColorChanged() {
			root.syncFromPenColor();
		}

		target: root.drawing
	}

	Canvas {
		id: canvas

		anchors.fill: parent
		renderStrategy: Canvas.Threaded
		renderTarget: Canvas.Image

		Component.onCompleted: requestPaint()
		onPaint: {
			const ctx = getContext("2d");
			ctx.reset();
			ctx.clearRect(0, 0, width, height);

			const cx = width / 2;
			const cy = height / 2;
			const radius = root.radius;
			const trackWidth = root.handleSize;

			// Background track: always show the full hue spectrum
			for (let i = 0; i < root.segmentCount; ++i) {
				const t1 = i / root.segmentCount;
				const t2 = (i + 1) / root.segmentCount;
				const a1 = root.arcStartAngle + root.arcSweep * t1;
				const a2 = root.arcStartAngle + root.arcSweep * t2;

				ctx.beginPath();
				ctx.arc(cx, cy, radius, a1, a2);
				ctx.lineWidth = trackWidth;
				ctx.lineCap = "round";
				ctx.strokeStyle = Qt.hsla(t1, 1.0, 0.5, 1.0);
				ctx.stroke();
			}
		}
	}

	Item {
		id: handle

		height: root.handleSize
		width: root.handleSize
		x: root.handleCenterX - width / 2
		y: root.handleCenterY - height / 2
		z: 1

		Elevation {
			anchors.fill: parent
			level: handleHover.containsMouse ? 2 : 1
			radius: rect.radius
		}

		Rectangle {
			id: rect

			anchors.fill: parent
			color: root.thumbColor
			radius: width / 2

			MouseArea {
				id: handleHover

				acceptedButtons: Qt.NoButton
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true
			}

			Rectangle {
				anchors.centerIn: parent
				color: root.drawing ? root.drawing.penColor : Qt.hsla(root.currentHue, 1.0, 0.5, 1.0)
				height: width
				radius: width / 2
				width: parent.width - 12
			}
		}
	}

	MouseArea {
		id: dragArea

		acceptedButtons: Qt.LeftButton
		anchors.fill: parent
		hoverEnabled: true

		onCanceled: {
			root.dragActive = false;
		}
		onPositionChanged: mouse => {
			if ((mouse.buttons & Qt.LeftButton) && root.dragActive)
				root.updateHueFromPoint(mouse.x, mouse.y, true);
		}
		onPressed: mouse => {
			root.dragActive = root.pointIsOnTrack(mouse.x, mouse.y);
			if (root.dragActive)
				root.updateHueFromPoint(mouse.x, mouse.y);
		}
		onReleased: {
			root.dragActive = false;
		}
	}
}
