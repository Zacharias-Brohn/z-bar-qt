pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQml.Models
import qs.Modules.Dock.Parts
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	readonly property int dockContentWidth: TaskbarApps.apps.reduce((sum, app, i) => sum + (app.appId === TaskbarApps.separatorId ? 1 : Config.dock.height) + (i > 0 ? dockRow.spacing : 0), 0)
	property bool dragActive: false
	property real dragHeight: Config.dock.height
	property real dragStartX: 0
	property real dragStartY: 0
	property real dragWidth: Config.dock.height
	property real dragX: 0
	property real dragY: 0
	property string draggedAppId: ""
	property var draggedModelData: null
	readonly property int padding: Appearance.padding.small
	required property var panels
	readonly property int rounding: Appearance.rounding.large
	required property PersistentProperties visibilities
	property var visualIds: []

	function beginVisualDrag(appId, modelData, item) {
		const pos = item.mapToItem(root, 0, 0);

		root.visualIds = TaskbarApps.apps.map(app => app.appId);
		root.draggedAppId = appId;
		root.draggedModelData = modelData;
		root.dragWidth = item.width;
		root.dragHeight = item.height;
		root.dragStartX = pos.x;
		root.dragStartY = pos.y;
		root.dragX = pos.x;
		root.dragY = pos.y;
		root.dragActive = true;
	}

	function endVisualDrag() {
		const ids = root.visualIds.slice();

		root.dragActive = false;
		root.draggedAppId = "";
		root.draggedModelData = null;
		root.visualIds = [];

		TaskbarApps.commitVisualOrder(ids);
	}

	function moveArrayItem(list, from, to) {
		const next = list.slice();
		const [item] = next.splice(from, 1);
		next.splice(to, 0, item);
		return next;
	}

	function previewVisualMove(from, hovered, before) {
		let to = hovered + (before ? 0 : 1);

		if (to > from)
			to -= 1;

		to = Math.max(0, Math.min(visualModel.items.count - 1, to));

		if (from === to)
			return;

		visualModel.items.move(from, to);
		root.visualIds = moveArrayItem(root.visualIds, from, to);
	}

	implicitHeight: Config.dock.height + root.padding * 2
	implicitWidth: root.dockContentWidth + root.padding * 2

	Component {
		id: dockDelegate

		DropArea {
			id: slot

			readonly property string appId: modelData.appId
			readonly property bool isSeparator: appId === TaskbarApps.separatorId
			required property var modelData

			function previewReorder(drag) {
				const source = drag.source;
				if (!source || !source.appId || source.appId === appId)
					return;

				const from = source.visualIndex;
				const hovered = slot.DelegateModel.itemsIndex;

				if (from < 0 || hovered < 0)
					return;

				root.previewVisualMove(from, hovered, drag.x < width / 2);
			}

			height: Config.dock.height
			width: isSeparator ? 1 : Config.dock.height

			onEntered: drag => previewReorder(drag)
			onPositionChanged: drag => previewReorder(drag)

			DockAppButton {
				id: button

				anchors.centerIn: parent
				appListRoot: root
				appToplevel: modelData
				visibilities: root.visibilities
				visible: root.draggedAppId !== slot.appId
			}

			DragHandler {
				id: dragHandler

				enabled: !slot.isSeparator
				grabPermissions: PointerHandler.CanTakeOverFromAnything
				target: null
				xAxis.enabled: true
				yAxis.enabled: false

				onActiveChanged: {
					if (active) {
						root.beginVisualDrag(slot.appId, slot.modelData, button);
					} else if (root.draggedAppId === slot.appId) {
						dragProxy.Drag.drop();
						root.endVisualDrag();
					}
				}
				onActiveTranslationChanged: {
					if (!active || root.draggedAppId !== slot.appId)
						return;

					root.dragX = root.dragStartX + activeTranslation.x;
					root.dragY = root.dragStartY + activeTranslation.y;
				}
			}
		}
	}

	DelegateModel {
		id: visualModel

		delegate: dockDelegate

		model: ScriptModel {
			objectProp: "appId"
			values: TaskbarApps.apps
		}
	}

	CustomListView {
		id: dockRow

		anchors.centerIn: parent
		boundsBehavior: Flickable.StopAtBounds
		implicitHeight: Config.dock.height
		implicitWidth: root.dockContentWidth
		interactive: !root.dragActive
		model: visualModel
		orientation: ListView.Horizontal
		spacing: Appearance.padding.smaller

		Behavior on implicitWidth {
			Anim {
			}
		}
		moveDisplaced: Transition {
			Anim {
				properties: "x,y"
			}
		}
	}

	Item {
		id: dragProxy

		property string appId: root.draggedAppId
		property int visualIndex: root.visualIds.indexOf(root.draggedAppId)

		Drag.active: root.dragActive
		Drag.hotSpot.x: width / 2
		Drag.hotSpot.y: height / 2
		Drag.source: dragProxy
		height: root.dragHeight
		visible: root.dragActive && !!root.draggedModelData
		width: root.dragWidth
		x: root.dragX
		y: root.dragY
		z: 9999

		DockAppButton {
			anchors.fill: parent
			appListRoot: root
			appToplevel: root.draggedModelData
			enabled: false
			visibilities: root.visibilities
		}
	}
}
