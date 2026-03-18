import Quickshell
import QtQuick
import qs.Components
import qs.Config

CustomMouseArea {
	id: root

	required property var bar
	required property Drawing drawing
	required property Panels panels
	required property var popout
	required property PersistentProperties visibilities

	function inLeftPanel(panel: Item, x: real, y: real): bool {
		return x < panel.x + panel.width + Config.barConfig.border && withinPanelHeight(panel, x, y);
	}

	function withinPanelHeight(panel: Item, x: real, y: real): bool {
		const panelY = panel.y + bar.implicitHeight;
		return y >= panelY && y <= panelY + panel.height;
	}

	acceptedButtons: Qt.LeftButton | Qt.RightButton
	anchors.fill: root.visibilities.isDrawing ? parent : undefined
	hoverEnabled: true
	visible: root.visibilities.isDrawing

	onPositionChanged: event => {
		const x = event.x;
		const y = event.y;

		if (event.buttons & Qt.LeftButton)
			root.drawing.appendPoint(x, y);

		if (root.inLeftPanel(root.popout, x, y)) {
			root.z = -2;
			root.panels.drawing.expanded = true;
		}
	}
	onPressed: event => {
		const x = event.x;
		const y = event.y;

		if (root.visibilities.isDrawing && (event.buttons & Qt.LeftButton)) {
			root.panels.drawing.expanded = false;
			root.drawing.beginStroke(x, y);
			return;
		}

		if (event.buttons & Qt.RightButton)
			root.drawing.clear();
	}
	onReleased: {
		if (root.visibilities.isDrawing)
			root.drawing.endStroke();
	}
}
