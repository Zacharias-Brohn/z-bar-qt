import qs.Components
import qs.Config
import qs.Daemons
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
	id: root

	readonly property int padding: 6
	required property Item panels
	required property PersistentProperties visibilities

	anchors.bottom: parent.bottom
	anchors.right: parent.right
	anchors.top: parent.top
	implicitHeight: {
		const count = list.count;
		if (count === 0)
			return 0;

		let height = (count - 1) * 8;
		for (let i = 0; i < count; i++)
			height += list.itemAtIndex(i)?.nonAnimHeight ?? 0;

		if (visibilities && panels) {
			if (visibilities.osd) {
				const h = panels.osd.y - 8 * 2 - padding * 2;
				if (height > h)
					height = h;
			}

			if (visibilities.session) {
				const h = panels.session.y - 8 * 2 - padding * 2;
				if (height > h)
					height = h;
			}
		}

		return Math.min((QsWindow.window?.screen?.height ?? 0) - 1 * 2, height + padding * 2);
	}
	implicitWidth: Config.notifs.sizes.width + padding * 2

	Behavior on implicitHeight {
		Anim {
		}
	}

	ClippingWrapperRectangle {
		anchors.fill: parent
		anchors.margins: root.padding
		color: "transparent"
		radius: 4

		CustomListView {
			id: list

			anchors.fill: parent
			cacheBuffer: QsWindow.window?.screen.height ?? 0
			orientation: Qt.Vertical
			spacing: 0

			delegate: Item {
				id: wrapper

				property int idx
				required property int index
				required property NotifServer.Notif modelData
				readonly property alias nonAnimHeight: notif.nonAnimHeight

				implicitHeight: notif.implicitHeight + (idx === 0 ? 0 : 8)
				implicitWidth: notif.implicitWidth

				ListView.onRemove: removeAnim.start()
				onIndexChanged: {
					if (index !== -1)
						idx = index;
				}

				SequentialAnimation {
					id: removeAnim

					PropertyAction {
						property: "ListView.delayRemove"
						target: wrapper
						value: true
					}

					PropertyAction {
						property: "enabled"
						target: wrapper
						value: false
					}

					PropertyAction {
						property: "implicitHeight"
						target: wrapper
						value: 0
					}

					PropertyAction {
						property: "z"
						target: wrapper
						value: 1
					}

					Anim {
						duration: MaterialEasing.expressiveEffectsTime
						easing.bezierCurve: MaterialEasing.expressiveEffects
						property: "x"
						target: notif
						to: (notif.x >= 0 ? Config.notifs.sizes.width : -Config.notifs.sizes.width) * 2
					}

					PropertyAction {
						property: "ListView.delayRemove"
						target: wrapper
						value: false
					}
				}

				ClippingRectangle {
					anchors.top: parent.top
					anchors.topMargin: wrapper.idx === 0 ? 0 : 8
					color: "transparent"
					implicitHeight: notif.implicitHeight
					implicitWidth: notif.implicitWidth
					radius: 4

					Notification {
						id: notif

						modelData: wrapper.modelData
					}
				}
			}
			displaced: Transition {
				Anim {
					property: "y"
				}
			}
			model: ScriptModel {
				values: NotifServer.popups.filter(n => !n.closed)
			}
			move: Transition {
				Anim {
					property: "y"
				}
			}

			ExtraIndicator {
				anchors.top: parent.top
				extra: {
					const count = list.count;
					if (count === 0)
						return 0;

					const scrollY = list.contentY;

					let height = 0;
					for (let i = 0; i < count; i++) {
						height += (list.itemAtIndex(i)?.nonAnimHeight ?? 0) + 8;

						if (height - 8 >= scrollY)
							return i;
					}

					return count;
				}
			}

			ExtraIndicator {
				anchors.bottom: parent.bottom
				extra: {
					const count = list.count;
					if (count === 0)
						return 0;

					const scrollY = list.contentHeight - (list.contentY + list.height);

					let height = 0;
					for (let i = count - 1; i >= 0; i--) {
						height += (list.itemAtIndex(i)?.nonAnimHeight ?? 0) + 8;

						if (height - 8 >= scrollY)
							return count - i - 1;
					}

					return 0;
				}
			}
		}
	}

	component Anim: NumberAnimation {
		duration: MaterialEasing.expressiveEffectsTime
		easing.bezierCurve: MaterialEasing.expressiveEffects
		easing.type: Easing.BezierSpline
	}
}
