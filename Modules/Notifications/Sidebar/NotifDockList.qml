pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import Quickshell
import QtQuick

Item {
	id: root

	required property Flickable container
	property bool flag
	required property Props props
	readonly property alias repeater: repeater
	readonly property int spacing: 8
	required property var visibilities

	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: {
		const item = repeater.itemAt(repeater.count - 1);
		return item ? item.y + item.implicitHeight : 0;
	}

	Repeater {
		id: repeater

		model: ScriptModel {
			values: {
				const map = new Map();
				for (const n of NotifServer.notClosed)
					map.set(n.appName, null);
				for (const n of NotifServer.list)
					map.set(n.appName, null);
				return [...map.keys()];
			}

			onValuesChanged: root.flagChanged()
		}

		MouseArea {
			id: notif

			readonly property bool closed: notifInner.notifCount === 0
			required property int index
			required property string modelData
			readonly property alias nonAnimHeight: notifInner.nonAnimHeight
			property int startY

			function closeAll(): void {
				for (const n of NotifServer.notClosed.filter(n => n.appName === modelData)) {
					n.close();
				}
			}

			acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
			cursorShape: pressed ? Qt.ClosedHandCursor : undefined
			drag.axis: Drag.XAxis
			drag.target: this
			enabled: !closed
			hoverEnabled: true
			implicitHeight: notifInner.implicitHeight
			implicitWidth: root.width
			preventStealing: true
			y: {
				root.flag; // Force update
				let y = 0;
				for (let i = 0; i < index; i++) {
					const item = repeater.itemAt(i);
					if (!item.closed)
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

			onPositionChanged: event => {
				if (pressed) {
					const diffY = event.y - startY;
					if (Math.abs(diffY) > Config.notifs.expandThreshold)
						notifInner.toggleExpand(diffY > 0);
				}
			}
			onPressed: event => {
				startY = event.y;
				if (event.button === Qt.RightButton)
					notifInner.toggleExpand(!notifInner.expanded);
				else if (event.button === Qt.MiddleButton)
					closeAll();
			}
			onReleased: event => {
				if (Math.abs(x) < width * Config.notifs.clearThreshold)
					x = 0;
				else
					closeAll();
			}

			ParallelAnimation {
				running: true

				Anim {
					from: 0
					property: "opacity"
					target: notif
					to: 1
				}

				Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
					from: 0
					property: "scale"
					target: notif
					to: 1
				}
			}

			ParallelAnimation {
				running: notif.closed

				Anim {
					property: "opacity"
					target: notif
					to: 0
				}

				Anim {
					property: "scale"
					target: notif
					to: 0.6
				}
			}

			NotifGroup {
				id: notifInner

				container: root.container
				modelData: notif.modelData
				props: root.props
				visibilities: root.visibilities
			}
		}
	}
}
