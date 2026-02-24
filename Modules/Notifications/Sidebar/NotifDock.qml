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

	readonly property int notifCount: NotifServer.list.reduce((acc, n) => n.closed ? acc : acc + 1, 0)
	required property Props props
	required property var visibilities

	anchors.fill: parent
	anchors.margins: 8

	Component.onCompleted: NotifServer.list.forEach(n => n.popup = false)

	Item {
		id: title

		anchors.left: parent.left
		anchors.margins: 4
		anchors.right: parent.right
		anchors.top: parent.top
		implicitHeight: Math.max(count.implicitHeight, titleText.implicitHeight)

		CustomText {
			id: count

			anchors.left: parent.left
			anchors.leftMargin: root.notifCount > 0 ? 0 : -width - titleText.anchors.leftMargin
			anchors.verticalCenter: parent.verticalCenter
			color: DynamicColors.palette.m3outline
			font.family: "CaskaydiaCove NF"
			font.pointSize: 13
			font.weight: 500
			opacity: root.notifCount > 0 ? 1 : 0
			text: root.notifCount

			Behavior on anchors.leftMargin {
				Anim {
				}
			}
			Behavior on opacity {
				Anim {
				}
			}
		}

		CustomText {
			id: titleText

			anchors.left: count.right
			anchors.leftMargin: 7
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			color: DynamicColors.palette.m3outline
			elide: Text.ElideRight
			font.family: "CaskaydiaCove NF"
			font.pointSize: 13
			font.weight: 500
			text: root.notifCount > 0 ? qsTr("notification%1").arg(root.notifCount === 1 ? "" : "s") : qsTr("Notifications")
		}
	}

	ClippingRectangle {
		id: clipRect

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: title.bottom
		anchors.topMargin: 10
		color: "transparent"
		radius: 6

		Loader {
			active: opacity > 0
			anchors.centerIn: parent
			opacity: root.notifCount > 0 ? 0 : 1

			Behavior on opacity {
				Anim {
					duration: MaterialEasing.expressiveEffectsTime
				}
			}
			sourceComponent: ColumnLayout {
				spacing: 20

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3outlineVariant
					font.family: "CaskaydiaCove NF"
					font.pointSize: 18
					font.weight: 500
					text: qsTr("No Notifications")
				}
			}
		}

		CustomFlickable {
			id: view

			anchors.fill: parent
			contentHeight: notifList.implicitHeight
			contentWidth: width
			flickableDirection: Flickable.VerticalFlick

			CustomScrollBar.vertical: CustomScrollBar {
				flickable: view
			}

			NotifDockList {
				id: notifList

				container: view
				props: root.props
				visibilities: root.visibilities
			}
		}
	}

	Timer {
		id: clearTimer

		interval: 50
		repeat: true

		onTriggered: {
			let next = null;
			for (let i = 0; i < notifList.repeater.count; i++) {
				next = notifList.repeater.itemAt(i);
				if (!next?.closed)
					break;
			}
			if (next)
				next.closeAll();
			else
				stop();
		}
	}

	Loader {
		active: opacity > 0
		anchors.bottom: parent.bottom
		anchors.margins: 8
		anchors.right: parent.right
		opacity: root.notifCount > 0 ? 1 : 0
		scale: root.notifCount > 0 ? 1 : 0.5

		Behavior on opacity {
			Anim {
				duration: MaterialEasing.expressiveEffectsTime
			}
		}
		Behavior on scale {
			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}
		sourceComponent: IconButton {
			id: clearBtn

			font.pointSize: Math.round(18 * 1.2)
			icon: "clear_all"
			padding: 8
			radius: 8

			onClicked: clearTimer.start()

			Elevation {
				anchors.fill: parent
				level: clearBtn.stateLayer.containsMouse ? 4 : 3
				radius: parent.radius
				z: -1
			}
		}
	}
}
