pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
	id: root

	required property Flickable container
	required property bool expanded
	property bool flag
	readonly property real nonAnimHeight: {
		let h = -root.spacing;
		for (let i = 0; i < repeater.count; i++) {
			const item = repeater.itemAt(i);
			if (!item.modelData.closed && !item.previewHidden)
				h += item.nonAnimHeight + root.spacing;
		}
		return h;
	}
	required property list<var> notifs
	required property Props props
	property bool showAllNotifs
	readonly property int spacing: Math.round(7 / 2)
	required property var visibilities

	signal requestToggleExpand(expand: bool)

	Layout.fillWidth: true
	implicitHeight: nonAnimHeight

	Behavior on implicitHeight {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	onExpandedChanged: {
		if (expanded) {
			clearTimer.stop();
			showAllNotifs = true;
		} else {
			clearTimer.start();
		}
	}

	Timer {
		id: clearTimer

		interval: MaterialEasing.standardTime

		onTriggered: root.showAllNotifs = false
	}

	Repeater {
		id: repeater

		model: ScriptModel {
			values: root.showAllNotifs ? root.notifs : root.notifs.slice(0, Config.notifs.groupPreviewNum + 1)

			onValuesChanged: root.flagChanged()
		}

		MouseArea {
			id: notif

			required property int index
			required property NotifServer.Notif modelData
			readonly property alias nonAnimHeight: notifInner.nonAnimHeight
			readonly property bool previewHidden: {
				if (root.expanded)
					return false;

				let extraHidden = 0;
				for (let i = 0; i < index; i++)
					if (root.notifs[i].closed)
						extraHidden++;

				return index >= Config.notifs.groupPreviewNum + extraHidden;
			}
			property int startY

			acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
			cursorShape: notifInner.body?.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
			drag.axis: Drag.XAxis
			drag.target: this
			enabled: !modelData.closed
			hoverEnabled: true
			implicitHeight: notifInner.implicitHeight
			implicitWidth: root.width
			opacity: previewHidden ? 0 : 1
			preventStealing: !root.expanded
			scale: previewHidden ? 0.7 : 1
			y: {
				root.flag; // Force update
				let y = 0;
				for (let i = 0; i < index; i++) {
					const item = repeater.itemAt(i);
					if (!item.modelData.closed && !item.previewHidden)
						y += item.nonAnimHeight + root.spacing;
				}
				return y;
			}

			containmentMask: QtObject {
				function contains(p: point): bool {
					if (!root.container.contains(notif.mapToItem(root.container, p)))
						return false;
					return notifInner.contains(p);
				}
			}
			Behavior on opacity {
				Anim {
				}
			}
			Behavior on scale {
				Anim {
				}
			}
			Behavior on x {
				Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
				}
			}
			Behavior on y {
				Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
				}
			}

			Component.onCompleted: modelData.lock(this)
			Component.onDestruction: modelData.unlock(this)
			onPositionChanged: event => {
				if (pressed && !root.expanded) {
					const diffY = event.y - startY;
					if (Math.abs(diffY) > Config.notifs.expandThreshold)
						root.requestToggleExpand(diffY > 0);
				}
			}
			onPressed: event => {
				startY = event.y;
				if (event.button === Qt.RightButton)
					root.requestToggleExpand(!root.expanded);
				else if (event.button === Qt.MiddleButton)
					modelData.close();
			}
			onReleased: event => {
				if (Math.abs(x) < width * Config.notifs.clearThreshold)
					x = 0;
				else
					modelData.close();
			}

			ParallelAnimation {
				Component.onCompleted: running = !notif.previewHidden

				Anim {
					from: 0
					property: "opacity"
					target: notif
					to: 1
				}

				Anim {
					from: 0.7
					property: "scale"
					target: notif
					to: 1
				}
			}

			ParallelAnimation {
				running: notif.modelData.closed

				onFinished: notif.modelData.unlock(notif)

				Anim {
					property: "opacity"
					target: notif
					to: 0
				}

				Anim {
					property: "x"
					target: notif
					to: notif.x >= 0 ? notif.width : -notif.width
				}
			}

			Notif {
				id: notifInner

				anchors.fill: parent
				expanded: root.expanded
				modelData: notif.modelData
				props: root.props
				visibilities: root.visibilities
			}
		}
	}
}
