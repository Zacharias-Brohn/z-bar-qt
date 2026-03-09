pragma ComponentBehavior: Bound

import QtQuick

Item {
	id: root

	readonly property real arcStartAngle: 0.75 * Math.PI
	readonly property real arcSweep: 1.5 * Math.PI
	property real currentHue: 0
	required property var drawing
	property real handleSize: 30
	property real lastChromaticHue: 0
	property real ringThickness: 12
	readonly property int segmentCount: 180

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

	function syncFromPenColor() {
		if (!drawing)
			return;

		const c = drawing.penColor;

		// QML color exposes HSL channels directly.
		// If the current color is chromatic, move the handle to that hue.
		// If it is achromatic (black/white/gray), keep the last useful hue.
		if (c.hslSaturation > 0) {
			currentHue = c.hslHue;
			lastChromaticHue = c.hslHue;
		} else {
			currentHue = lastChromaticHue;
		}

		canvas.requestPaint();
	}

	function updateHueFromPoint(x, y) {
		const cx = canvas.width / 2;
		const cy = canvas.height / 2;
		const dx = x - cx;
		const dy = y - cy;

		const distance = Math.sqrt(dx * dx + dy * dy);
		const radius = (Math.min(canvas.width, canvas.height) - handleSize - 8) / 2;

		if (distance < radius - 24 || distance > radius + 24)
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
		drawing.penColor = Qt.hsla(currentHue, 1.0, 0.5, 1.0);
	}

	implicitHeight: 180
	implicitWidth: 220

	Component.onCompleted: syncFromPenColor()
	onCurrentHueChanged: canvas.requestPaint()
	onDrawingChanged: syncFromPenColor()

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
		onHeightChanged: requestPaint()
		onPaint: {
			const ctx = getContext("2d");
			ctx.reset();
			ctx.clearRect(0, 0, width, height);

			const cx = width / 2;
			const cy = height / 2;
			const radius = (Math.min(width, height) - root.handleSize - 8) / 2;

			ctx.beginPath();
			ctx.arc(cx, cy, radius, root.arcStartAngle, root.arcStartAngle + root.arcSweep);
			ctx.lineWidth = root.ringThickness + 4;
			ctx.lineCap = "round";
			ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.12);
			ctx.stroke();

			for (let i = 0; i < root.segmentCount; ++i) {
				const t1 = i / root.segmentCount;
				const t2 = (i + 1) / root.segmentCount;
				const a1 = root.arcStartAngle + root.arcSweep * t1;
				const a2 = root.arcStartAngle + root.arcSweep * t2;

				ctx.beginPath();
				ctx.arc(cx, cy, radius, a1, a2);
				ctx.lineWidth = root.ringThickness;
				ctx.lineCap = "round";
				ctx.strokeStyle = Qt.hsla(t1, 1.0, 0.5, 1.0);
				ctx.stroke();
			}

			const handleAngle = root.hueToAngle(root.currentHue);
			const hx = cx + radius * Math.cos(handleAngle);
			const hy = cy + radius * Math.sin(handleAngle);

			ctx.beginPath();
			ctx.arc(hx, hy, root.handleSize / 2, 0, Math.PI * 2);
			ctx.fillStyle = Qt.rgba(1, 1, 1, 0.95);
			ctx.fill();

			ctx.beginPath();
			ctx.arc(hx, hy, root.handleSize / 2, 0, Math.PI * 2);
			ctx.lineWidth = 1.5;
			ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.18);
			ctx.stroke();

			ctx.beginPath();
			ctx.arc(hx, hy, root.handleSize / 2 - 6, 0, Math.PI * 2);
			ctx.fillStyle = root.drawing.penColor;
			ctx.fill();

			ctx.beginPath();
			ctx.arc(hx, hy, root.handleSize / 2 - 6, 0, Math.PI * 2);
			ctx.lineWidth = 1;
			ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.20);
			ctx.stroke();
		}
		onWidthChanged: requestPaint()
	}

	MouseArea {
		acceptedButtons: Qt.LeftButton
		anchors.fill: parent

		onPositionChanged: mouse => {
			if (mouse.buttons & Qt.LeftButton)
				root.updateHueFromPoint(mouse.x, mouse.y);
		}
		onPressed: mouse => root.updateHueFromPoint(mouse.x, mouse.y)
	}
}
