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
	property bool dropAnimating: false
	readonly property int padding: Appearance.padding.small
	required property var panels
	property var pendingCommitIds: []
	readonly property int rounding: Appearance.rounding.large
	required property ShellScreen screen
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
		root.dropAnimating = false;
		root.pendingCommitIds = [];
	}

	function endVisualDrag() {
		const ids = root.visualIds.slice();
		const finalIndex = root.visualIds.indexOf(root.draggedAppId);
		const finalItem = dockRow.itemAtIndex(finalIndex);

		// Stop sending drag events now, but keep the proxy alive while it settles.
		root.dragActive = false;

		// In a dock, the destination delegate should normally be instantiated.
		// If not, just finish immediately.
		if (!finalItem) {
			root.pendingCommitIds = ids;
			root.finishVisualDrag();
			return;
		}

		const pos = finalItem.mapToItem(root, 0, 0);

		root.pendingCommitIds = ids;
		root.dropAnimating = true;

		settleX.to = pos.x;
		settleY.to = pos.y;
		settleAnim.start();
	}

	function finishVisualDrag() {
		const ids = root.pendingCommitIds.slice();

		root.dragActive = false;
		root.dropAnimating = false;
		root.draggedAppId = "";
		root.draggedModelData = null;
		root.visualIds = [];
		root.pendingCommitIds = [];

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
	implicitWidth: dockRow.contentWidth + root.padding * 2

	ParallelAnimation {
		id: settleAnim

		onFinished: root.finishVisualDrag()

		Anim {
			id: settleX

			duration: Appearance.anim.durations.normal
			property: "dragX"
			target: root
		}

		Anim {
			id: settleY

			duration: Appearance.anim.durations.normal
			property: "dragY"
			target: root
		}
	}

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

			ListView.onRemove: removeAnim.start()
			onEntered: drag => previewReorder(drag)
			onPositionChanged: drag => previewReorder(drag)

			SequentialAnimation {
				id: removeAnim

				ScriptAction {
					script: slot.ListView.delayRemove = true
				}

				ParallelAnimation {
					Anim {
						property: "opacity"
						target: slot
						to: 0
					}

					Anim {
						property: "scale"
						target: slot
						to: 0.5
					}
				}

				ScriptAction {
					script: {
						slot.ListView.delayRemove = false;
					}
				}
			}

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

		property bool enableAddAnimation: false

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.top: parent.top
		boundsBehavior: Flickable.StopAtBounds
		height: Config.dock.height
		implicitWidth: root.dockContentWidth + Config.dock.height
		interactive: !(root.dragActive || root.dropAnimating)
		model: visualModel
		orientation: ListView.Horizontal
		spacing: Appearance.padding.smaller

		add: Transition {
			ParallelAnimation {
				Anim {
					duration: dockRow.enableAddAnimation ? Appearance.anim.durations.normal : 0
					from: 0
					property: "opacity"
					to: 1
				}

				Anim {
					duration: dockRow.enableAddAnimation ? Appearance.anim.durations.normal : 0
					from: 0.5
					property: "scale"
					to: 1
				}
			}
		}
		displaced: Transition {
			Anim {
				duration: Appearance.anim.durations.small
				properties: "x,y"
			}
		}
		move: Transition {
			Anim {
				duration: Appearance.anim.durations.small
				properties: "x,y"
			}
		}

		Component.onCompleted: {
			Qt.callLater(() => enableAddAnimation = true);
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
		visible: (root.dragActive || root.dropAnimating) && !!root.draggedModelData
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
