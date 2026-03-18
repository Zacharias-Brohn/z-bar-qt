import QtQuick

Canvas {
	id: root

	property rect dirtyRect: Qt.rect(0, 0, 0, 0)
	property bool frameQueued: false
	property bool fullRepaintPending: true
	property point lastPoint: Qt.point(0, 0)
	property real minPointDistance: 2.0
	property color penColor: "white"
	property real penWidth: 4
	property var pendingSegments: []
	property bool strokeActive: false
	property var strokes: []

	function appendPoint(x, y) {
		if (!strokeActive || strokes.length === 0)
			return;
		const dx = x - lastPoint.x;
		const dy = y - lastPoint.y;

		if ((dx * dx + dy * dy) < (minPointDistance * minPointDistance))
			return;
		const x1 = lastPoint.x;
		const y1 = lastPoint.y;
		const x2 = x;
		const y2 = y;

		strokes[strokes.length - 1].push(Qt.point(x2, y2));

		pendingSegments.push({
			dot: false,
			x1: x1,
			y1: y1,
			x2: x2,
			y2: y2
		});

		lastPoint = Qt.point(x2, y2);
		queueDirty(segmentDirtyRect(x1, y1, x2, y2));
	}

	function beginStroke(x, y) {
		const p = Qt.point(x, y);
		strokes.push([p]);
		lastPoint = p;
		strokeActive = true;

		pendingSegments.push({
			dot: true,
			x: x,
			y: y
		});

		queueDirty(pointDirtyRect(x, y));
	}

	function clear() {
		strokes = [];
		pendingSegments = [];
		dirtyRect = Qt.rect(0, 0, 0, 0);
		fullRepaintPending = true;
		markDirty(Qt.rect(0, 0, width, height));
	}

	function drawDot(ctx, x, y) {
		ctx.beginPath();
		ctx.arc(x, y, penWidth / 2, 0, Math.PI * 2);
		ctx.fill();
	}

	function drawSegment(ctx, x1, y1, x2, y2) {
		ctx.beginPath();
		ctx.moveTo(x1, y1);
		ctx.lineTo(x2, y2);
		ctx.stroke();
	}

	function endStroke() {
		strokeActive = false;
	}

	function pointDirtyRect(x, y) {
		const pad = penWidth + 2;
		return Qt.rect(x - pad, y - pad, pad * 2, pad * 2);
	}

	function queueDirty(r) {
		dirtyRect = unionRects(dirtyRect, r);

		if (frameQueued)
			return;
		frameQueued = true;

		requestAnimationFrame(function () {
			frameQueued = false;

			if (dirtyRect.width > 0 && dirtyRect.height > 0) {
				markDirty(dirtyRect);
				dirtyRect = Qt.rect(0, 0, 0, 0);
			}
		});
	}

	function replayAll(ctx) {
		ctx.clearRect(0, 0, width, height);

		for (const stroke of strokes) {
			if (!stroke || stroke.length === 0)
				continue;
			if (stroke.length === 1) {
				const p = stroke[0];
				drawDot(ctx, p.x, p.y);
				continue;
			}

			ctx.beginPath();
			ctx.moveTo(stroke[0].x, stroke[0].y);
			for (let i = 1; i < stroke.length; ++i)
				ctx.lineTo(stroke[i].x, stroke[i].y);
			ctx.stroke();
		}
	}

	function requestFullRepaint() {
		fullRepaintPending = true;
		markDirty(Qt.rect(0, 0, width, height));
	}

	function segmentDirtyRect(x1, y1, x2, y2) {
		const pad = penWidth + 2;
		const left = Math.min(x1, x2) - pad;
		const top = Math.min(y1, y2) - pad;
		const right = Math.max(x1, x2) + pad;
		const bottom = Math.max(y1, y2) + pad;
		return Qt.rect(left, top, right - left, bottom - top);
	}

	function unionRects(a, b) {
		if (a.width <= 0 || a.height <= 0)
			return b;
		if (b.width <= 0 || b.height <= 0)
			return a;

		const left = Math.min(a.x, b.x);
		const top = Math.min(a.y, b.y);
		const right = Math.max(a.x + a.width, b.x + b.width);
		const bottom = Math.max(a.y + a.height, b.y + b.height);

		return Qt.rect(left, top, right - left, bottom - top);
	}

	anchors.fill: parent
	contextType: "2d"
	renderStrategy: Canvas.Threaded
	renderTarget: Canvas.Image

	onHeightChanged: requestFullRepaint()
	onPaint: region => {
		const ctx = getContext("2d");

		ctx.lineCap = "round";
		ctx.lineJoin = "round";
		ctx.lineWidth = penWidth;
		ctx.strokeStyle = penColor;
		ctx.fillStyle = penColor;

		if (fullRepaintPending) {
			fullRepaintPending = false;
			replayAll(ctx);
			pendingSegments = [];
			return;
		}

		for (const seg of pendingSegments) {
			if (seg.dot)
				drawDot(ctx, seg.x, seg.y);
			else
				drawSegment(ctx, seg.x1, seg.y1, seg.x2, seg.y2);
		}

		pendingSegments = [];
	}
	onWidthChanged: requestFullRepaint()
}
