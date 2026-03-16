pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQml.Models
import qs.Components
import qs.Config

Item {
	id: root

	property bool dragActive: false
	property real dragHeight: 0
	property real dragStartX: 0
	property real dragStartY: 0
	property real dragX: 0
	property real dragY: 0
	property var draggedModelData: null
	property string draggedUid: ""
	property bool dropAnimating: false
	required property string name
	required property var object
	property var pendingCommitEntries: []
	required property string setting
	property int uidCounter: 0
	property var visualEntries: []

	function beginVisualDrag(uid, modelData, item) {
		const pos = item.mapToItem(root, 0, 0);

		root.draggedUid = uid;
		root.draggedModelData = modelData;
		root.dragHeight = item.height;
		root.dragStartX = pos.x;
		root.dragStartY = pos.y;
		root.dragX = pos.x;
		root.dragY = pos.y;
		root.dragActive = true;
		root.dropAnimating = false;
		root.pendingCommitEntries = [];
	}

	function commitVisualOrder(entries) {
		const list = [];

		for (let i = 0; i < entries.length; i++)
			list.push(entries[i].entry);

		root.object[root.setting] = list;
		Config.save();
		root.rebuildVisualEntries();
	}

	function endVisualDrag() {
		const entries = root.visualEntries.slice();
		const finalIndex = root.indexForUid(root.draggedUid);
		const finalItem = listView.itemAtIndex(finalIndex);

		root.dragActive = false;

		if (!finalItem) {
			root.pendingCommitEntries = entries;
			root.finishVisualDrag();
			return;
		}

		const pos = finalItem.mapToItem(root, 0, 0);

		root.pendingCommitEntries = entries;
		root.dropAnimating = true;
		settleX.to = pos.x;
		settleY.to = pos.y;
		settleAnim.start();
	}

	function ensureVisualEntries() {
		if (!root.dragActive && !root.dropAnimating)
			root.rebuildVisualEntries();
	}

	function finishVisualDrag() {
		const entries = root.pendingCommitEntries.slice();

		root.dragActive = false;
		root.dropAnimating = false;
		root.draggedUid = "";
		root.draggedModelData = null;
		root.pendingCommitEntries = [];
		root.dragHeight = 0;

		root.commitVisualOrder(entries);
	}

	function iconForId(id) {
		switch (id) {
		case "workspaces":
			return "dashboard";
		case "audio":
			return "volume_up";
		case "media":
			return "play_arrow";
		case "resources":
			return "monitoring";
		case "updates":
			return "system_update";
		case "dash":
			return "space_dashboard";
		case "spacer":
			return "horizontal_rule";
		case "activeWindow":
			return "web_asset";
		case "tray":
			return "widgets";
		case "upower":
			return "battery_full";
		case "network":
			return "wifi";
		case "clock":
			return "schedule";
		case "notifBell":
			return "notifications";
		default:
			return "drag_indicator";
		}
	}

	function indexForUid(uid) {
		for (let i = 0; i < root.visualEntries.length; i++) {
			if (root.visualEntries[i].uid === uid)
				return i;
		}

		return -1;
	}

	function labelForId(id) {
		switch (id) {
		case "workspaces":
			return qsTr("Workspaces");
		case "audio":
			return qsTr("Audio");
		case "media":
			return qsTr("Media");
		case "resources":
			return qsTr("Resources");
		case "updates":
			return qsTr("Updates");
		case "dash":
			return qsTr("Dash");
		case "spacer":
			return qsTr("Spacer");
		case "activeWindow":
			return qsTr("Active window");
		case "tray":
			return qsTr("Tray");
		case "upower":
			return qsTr("Power");
		case "network":
			return qsTr("Network");
		case "clock":
			return qsTr("Clock");
		case "notifBell":
			return qsTr("Notification bell");
		default:
			return id;
		}
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
		root.visualEntries = root.moveArrayItem(root.visualEntries, from, to);
	}

	function rebuildVisualEntries() {
		const entries = root.object[root.setting] ?? [];
		const next = [];

		for (let i = 0; i < entries.length; i++) {
			const entry = entries[i];
			let existing = null;

			for (let j = 0; j < root.visualEntries.length; j++) {
				if (root.visualEntries[j].entry === entry) {
					existing = root.visualEntries[j];
					break;
				}
			}

			if (existing)
				next.push(existing);
			else
				next.push({
					uid: `entry-${root.uidCounter++}`,
					entry
				});
		}

		root.visualEntries = next;
	}

	function updateEntry(index, value) {
		const list = [...root.object[root.setting]];
		const entry = list[index];
		entry.enabled = value;
		list[index] = entry;
		root.object[root.setting] = list;
		Config.save();
		root.ensureVisualEntries();
	}

	Layout.fillWidth: true
	implicitHeight: layout.implicitHeight

	Component.onCompleted: root.rebuildVisualEntries()

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

	ColumnLayout {
		id: layout

		anchors.fill: parent
		spacing: Appearance.spacing.smaller

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		DelegateModel {
			id: visualModel

			delegate: entryDelegate

			model: ScriptModel {
				objectProp: "uid"
				values: root.visualEntries
			}
		}

		ListView {
			id: listView

			Layout.fillWidth: true
			Layout.preferredHeight: contentHeight
			boundsBehavior: Flickable.StopAtBounds
			clip: false
			implicitHeight: contentHeight
			implicitWidth: width
			interactive: !(root.dragActive || root.dropAnimating)
			model: visualModel
			spacing: Appearance.spacing.small

			add: Transition {
				Anim {
					properties: "opacity,scale"
					to: 1
				}
			}
			addDisplaced: Transition {
				Anim {
					duration: Appearance.anim.durations.normal
					property: "y"
				}
			}
			displaced: Transition {
				Anim {
					duration: Appearance.anim.durations.normal
					property: "y"
				}
			}
			move: Transition {
				Anim {
					duration: Appearance.anim.durations.normal
					property: "y"
				}
			}
			removeDisplaced: Transition {
				Anim {
					duration: Appearance.anim.durations.normal
					property: "y"
				}
			}
		}
	}

	Loader {
		active: root.dragActive || root.dropAnimating
		asynchronous: false

		sourceComponent: Item {
			Drag.active: root.dragActive
			Drag.hotSpot.x: width / 2
			Drag.hotSpot.y: height / 2
			height: proxyRect.implicitHeight
			implicitHeight: proxyRect.implicitHeight
			implicitWidth: listView.width
			visible: root.draggedModelData !== null
			width: listView.width
			x: root.dragX
			y: root.dragY
			z: 100

			Drag.source: QtObject {
				property string uid: root.draggedUid
				property int visualIndex: root.indexForUid(root.draggedUid)
			}

			CustomRect {
				id: proxyRect

				color: DynamicColors.tPalette.m3surface
				implicitHeight: proxyRow.implicitHeight + Appearance.padding.small * 2
				implicitWidth: parent.width
				opacity: 0.95
				radius: Appearance.rounding.normal
				width: parent.width

				RowLayout {
					id: proxyRow

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					spacing: Appearance.spacing.normal

					CustomRect {
						color: Qt.alpha(DynamicColors.palette.m3onSurface, 0.12)
						implicitHeight: 32
						implicitWidth: implicitHeight
						radius: Appearance.rounding.small

						MaterialIcon {
							anchors.centerIn: parent
							color: DynamicColors.palette.m3onSurfaceVariant
							text: "drag_indicator"
						}
					}

					MaterialIcon {
						color: DynamicColors.palette.m3onSurfaceVariant
						text: root.iconForId(root.draggedModelData?.entry?.id ?? "")
					}

					CustomText {
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: root.labelForId(root.draggedModelData?.entry?.id ?? "")
					}

					CustomSwitch {
						checked: root.draggedModelData?.entry?.enabled ?? true
						enabled: false
					}
				}
			}
		}
	}

	Component {
		id: entryDelegate

		DropArea {
			id: slot

			readonly property var entryData: modelData.entry
			required property var modelData
			readonly property string uid: modelData.uid

			function previewReorder(drag) {
				const source = drag.source;
				if (!source || !source.uid || source.uid === slot.uid)
					return;

				const from = source.visualIndex;
				const hovered = slot.DelegateModel.itemsIndex;

				if (from < 0 || hovered < 0)
					return;

				root.previewVisualMove(from, hovered, drag.y < height / 2);
			}

			height: entryRow.implicitHeight
			implicitHeight: entryRow.implicitHeight
			implicitWidth: listView.width
			width: ListView.view ? ListView.view.width : listView.width

			onEntered: drag => previewReorder(drag)
			onPositionChanged: drag => previewReorder(drag)

			CustomRect {
				id: entryRow

				anchors.fill: parent
				color: DynamicColors.tPalette.m3surface
				implicitHeight: entryLayout.implicitHeight + Appearance.padding.small * 2
				implicitWidth: parent.width
				opacity: root.draggedUid === slot.uid ? 0 : 1
				radius: Appearance.rounding.full

				Behavior on opacity {
					Anim {
					}
				}

				RowLayout {
					id: entryLayout

					anchors.fill: parent
					anchors.margins: Appearance.padding.small
					spacing: Appearance.spacing.normal

					CustomRect {
						id: handle

						color: Qt.alpha(DynamicColors.palette.m3onSurface, handleDrag.active ? 0.12 : handleHover.hovered ? 0.09 : 0.06)
						implicitHeight: 32
						implicitWidth: implicitHeight
						radius: Appearance.rounding.full

						Behavior on color {
							CAnim {
							}
						}

						MaterialIcon {
							anchors.centerIn: parent
							color: DynamicColors.palette.m3onSurfaceVariant
							text: "drag_indicator"
						}

						HoverHandler {
							id: handleHover

							cursorShape: handleDrag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
						}

						DragHandler {
							id: handleDrag

							enabled: true
							grabPermissions: PointerHandler.CanTakeOverFromAnything
							target: null
							xAxis.enabled: false
							yAxis.enabled: true

							onActiveChanged: {
								if (active) {
									root.beginVisualDrag(slot.uid, slot.modelData, entryRow);
								} else if (root.draggedUid === slot.uid) {
									root.endVisualDrag();
								}
							}
							onActiveTranslationChanged: {
								if (!active || root.draggedUid !== slot.uid)
									return;

								root.dragX = root.dragStartX;
								root.dragY = root.dragStartY + activeTranslation.y;
							}
						}
					}

					MaterialIcon {
						color: DynamicColors.palette.m3onSurfaceVariant
						text: root.iconForId(slot.entryData.id)
					}

					CustomText {
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: root.labelForId(slot.entryData.id)
					}

					CustomSwitch {
						Layout.rightMargin: Appearance.padding.small
						checked: slot.entryData.enabled ?? true

						onToggled: root.updateEntry(slot.DelegateModel.itemsIndex, checked)
					}
				}
			}
		}
	}
}
