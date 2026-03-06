pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
	id: root

	required property NotifServer.Notif notif

	Layout.fillWidth: true
	implicitHeight: flickable.contentHeight

	CustomFlickable {
		id: flickable

		anchors.fill: parent
		contentHeight: actionList.implicitHeight
		contentWidth: Math.max(width, actionList.implicitWidth)

		RowLayout {
			id: actionList

			anchors.fill: parent
			spacing: 7

			Repeater {
				model: [
					{
						isClose: true
					},
					...root.notif.actions,
					{
						isCopy: true
					}
				]

				CustomRect {
					id: action

					required property var modelData

					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.preferredWidth: implicitWidth + (actionStateLayer.pressed ? 18 : 0)
					color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 4)
					implicitHeight: actionInner.implicitHeight + 5 * 2
					implicitWidth: actionInner.implicitWidth + 5 * 2
					radius: actionStateLayer.pressed ? 6 / 2 : 6

					Behavior on Layout.preferredWidth {
						Anim {
							duration: MaterialEasing.expressiveEffectsTime
							easing.bezierCurve: MaterialEasing.expressiveEffects
						}
					}
					Behavior on radius {
						Anim {
							duration: MaterialEasing.expressiveEffectsTime
							easing.bezierCurve: MaterialEasing.expressiveEffects
						}
					}

					Timer {
						id: copyTimer

						interval: 1000

						onTriggered: actionInner.item.text = "content_copy"
					}

					StateLayer {
						id: actionStateLayer

						function onClicked(): void {
							if (action.modelData.isClose) {
								root.notif.close();
							} else if (action.modelData.isCopy) {
								Quickshell.clipboardText = root.notif.body;
								actionInner.item.text = "inventory";
								copyTimer.start();
							} else if (action.modelData.invoke) {
								action.modelData.invoke();
							} else if (!root.notif.resident) {
								root.notif.close();
							}
						}
					}

					Loader {
						id: actionInner

						anchors.centerIn: parent
						sourceComponent: action.modelData.isClose || action.modelData.isCopy ? iconBtn : root.notif.hasActionIcons ? iconComp : textComp
					}

					Component {
						id: iconBtn

						MaterialIcon {
							animate: action.modelData.isCopy ?? false
							color: DynamicColors.palette.m3onSurfaceVariant
							text: action.modelData.isCopy ? "content_copy" : "close"
						}
					}

					Component {
						id: iconComp

						IconImage {
							source: Quickshell.iconPath(action.modelData.identifier)
						}
					}

					Component {
						id: textComp

						CustomText {
							color: DynamicColors.palette.m3onSurfaceVariant
							text: action.modelData.text
						}
					}
				}
			}
		}
	}
}
