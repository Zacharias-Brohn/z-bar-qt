import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Modules as BarPopouts

CustomMouseArea {
	id: root

	required property Item bar
	property bool dashboardShortcutActive
	property point dragStart
	required property Drawing drawing
	required property DrawingInput input
	property bool osdShortcutActive
	required property Panels panels
	required property BarPopouts.Wrapper popouts
	required property ShellScreen screen
	property bool utilitiesShortcutActive
	required property PersistentProperties visibilities

	function inBottomPanel(panel: Item, x: real, y: real): bool {
		return y > root.height - panel.height - Config.barConfig.border && withinPanelWidth(panel, x, y);
	}

	function inLeftPanel(panel: Item, x: real, y: real): bool {
		return x < panel.x + panel.width + Config.barConfig.border && withinPanelHeight(panel, x, y);
	}

	function inRightPanel(panel: Item, x: real, y: real): bool {
		return x > panel.x - Config.barConfig.border && withinPanelHeight(panel, x, y);
	}

	function inTopPanel(panel: Item, x: real, y: real): bool {
		return y < bar.implicitHeight + panel.height && withinPanelWidth(panel, x, y);
	}

	function onWheel(event: WheelEvent): void {
		if (event.x < bar.implicitWidth) {
			bar.handleWheel(event.y, event.angleDelta);
		}
	}

	function withinPanelHeight(panel: Item, x: real, y: real): bool {
		const panelY = panel.y + bar.implicitHeight;
		return y >= panelY && y <= panelY + panel.height;
	}

	function withinPanelWidth(panel: Item, x: real, y: real): bool {
		const panelX = panel.x;
		return x >= panelX && x <= panelX + panel.width;
	}

	anchors.fill: parent
	hoverEnabled: true
	propagateComposedEvents: true

	onContainsMouseChanged: {
		if (!containsMouse) {
			if (!osdShortcutActive) {
				visibilities.osd = false;
				root.panels.osd.hovered = false;
			}

			if (!popouts.currentName.startsWith("traymenu")) {
				popouts.hasCurrent = false;
			}

			if (Config.barConfig.autoHide)
				bar.isHovered = false;
		}
	}
	onPositionChanged: event => {
		if (popouts.isDetached)
			return;

		const x = event.x;
		const y = event.y;
		const dragX = x - dragStart.x;
		const dragY = y - dragStart.y;

		if (root.visibilities.isDrawing && !root.inLeftPanel(root.panels.drawing, x, y)) {
			root.input.z = 2;
			root.panels.drawing.expanded = false;
		}

		if (!visibilities.bar && Config.barConfig.autoHide && y < bar.implicitHeight)
			bar.isHovered = true;

		if (panels.sidebar.width === 0) {
			const showOsd = inRightPanel(panels.osd, x, y);

			if (showOsd) {
				osdShortcutActive = false;
				root.panels.osd.hovered = true;
			}
		} else {
			const outOfSidebar = x < width - panels.sidebar.width;
			const showOsd = outOfSidebar && inRightPanel(panels.osd, x, y);

			if (!osdShortcutActive) {
				visibilities.osd = showOsd;
				root.panels.osd.hovered = showOsd;
			} else if (showOsd) {
				osdShortcutActive = false;
				root.panels.osd.hovered = true;
			}
		}

		if (y < root.bar.implicitHeight) {
			root.bar.checkPopout(x);
		}
	}

	Connections {
		function onDashboardChanged() {
			if (root.visibilities.dashboard) {
				const inDashboardArea = root.inTopPanel(root.panels.dashboard, root.mouseX, root.mouseY);
				if (!inDashboardArea) {
					root.dashboardShortcutActive = true;
				}

				root.visibilities.sidebar = false;
				root.popouts.hasCurrent = false;
			} else {
				root.dashboardShortcutActive = false;
			}
		}

		function onIsDrawingChanged() {
			if (!root.visibilities.isDrawing)
				root.drawing.clear();
		}

		function onLauncherChanged() {
			if (!root.visibilities.launcher) {
				root.dashboardShortcutActive = false;
				root.osdShortcutActive = false;
				root.utilitiesShortcutActive = false;

				const inOsdArea = root.inRightPanel(root.panels.osd, root.mouseX, root.mouseY);

				if (!inOsdArea) {
					root.visibilities.osd = false;
					root.panels.osd.hovered = false;
				}
			}
		}

		function onOsdChanged() {
			if (root.visibilities.osd) {
				const inOsdArea = root.inRightPanel(root.panels.osd, root.mouseX, root.mouseY);
				if (!inOsdArea) {
					root.osdShortcutActive = true;
				}
			} else {
				root.osdShortcutActive = false;
			}
		}

		function onResourcesChanged() {
			if (root.visibilities.resources && root.popouts.currentName.startsWith("audio")) {
				root.popouts.hasCurrent = false;
			}
		}

		function onSidebarChanged() {
			if (root.visibilities.sidebar) {
				root.visibilities.dashboard = false;
				root.popouts.hasCurrent = false;
			}
		}

		function onUtilitiesChanged() {
			if (root.visibilities.utilities) {
				const inUtilitiesArea = root.inBottomPanel(root.panels.utilities, root.mouseX, root.mouseY);
				if (!inUtilitiesArea) {
					root.utilitiesShortcutActive = true;
				}
			} else {
				root.utilitiesShortcutActive = false;
			}
		}

		target: root.visibilities
	}
}
