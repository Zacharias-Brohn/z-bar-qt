import QtQuick

Path {
	id: root

	required property real viewHeight
	required property real viewWidth

	startX: root.viewWidth / 2
	startY: 0

	PathAttribute {
		name: "itemOpacity"
		value: 0.25
	}

	PathLine {
		x: root.viewWidth / 2
		y: root.viewHeight * (1 / 6)
	}

	PathAttribute {
		name: "itemOpacity"
		value: 0.45
	}

	PathLine {
		x: root.viewWidth / 2
		y: root.viewHeight * (2 / 6)
	}

	PathAttribute {
		name: "itemOpacity"
		value: 0.70
	}

	PathLine {
		x: root.viewWidth / 2
		y: root.viewHeight * (3 / 6)
	}

	PathAttribute {
		name: "itemOpacity"
		value: 1.00
	}

	PathLine {
		x: root.viewWidth / 2
		y: root.viewHeight * (4 / 6)
	}

	PathAttribute {
		name: "itemOpacity"
		value: 0.70
	}

	PathLine {
		x: root.viewWidth / 2
		y: root.viewHeight * (5 / 6)
	}

	PathAttribute {
		name: "itemOpacity"
		value: 0.45
	}

	PathLine {
		x: root.viewWidth / 2
		y: root.viewHeight
	}

	PathAttribute {
		name: "itemOpacity"
		value: 0.25
	}
}
