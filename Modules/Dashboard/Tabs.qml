pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Helpers
import qs.Modules
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

Item {
	id: root

	readonly property alias count: bar.count
	required property real nonAnimWidth
	required property PersistentProperties state

	implicitHeight: bar.implicitHeight + indicator.implicitHeight + indicator.anchors.topMargin + separator.implicitHeight

	TabBar {
		id: bar

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		background: null
		currentIndex: root.state.currentTab

		onCurrentIndexChanged: root.state.currentTab = currentIndex

		Tab {
			iconName: "dashboard"
			text: qsTr("Dashboard")
		}

		Tab {
			iconName: "queue_music"
			text: qsTr("Media")
		}

		Tab {
			iconName: "speed"
			text: qsTr("Performance")
		}

		Tab {
			iconName: "cloud"
			text: qsTr("Weather")
		}

		// Tab {
		//     iconName: "workspaces"
		//     text: qsTr("Workspaces")
		// }
	}

	Item {
		id: indicator

		anchors.top: bar.bottom
		clip: true
		implicitHeight: 40
		implicitWidth: bar.currentItem.implicitWidth
		x: {
			const tab = bar.currentItem;
			const width = (root.nonAnimWidth - bar.spacing * (bar.count - 1)) / bar.count;
			return width * tab.TabBar.index + (width - tab.implicitWidth) / 2;
		}

		Behavior on implicitWidth {
			Anim {
			}
		}
		Behavior on x {
			Anim {
			}
		}

		CustomRect {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			color: DynamicColors.palette.m3primary
			implicitHeight: parent.implicitHeight * 2
			radius: 1000
		}
	}

	CustomRect {
		id: separator

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: indicator.bottom
		color: DynamicColors.palette.m3outlineVariant
		implicitHeight: 1
	}

	component Tab: TabButton {
		id: tab

		readonly property bool current: TabBar.tabBar.currentItem === this
		required property string iconName

		background: null

		contentItem: CustomMouseArea {
			id: mouse

			function onWheel(event: WheelEvent): void {
				if (event.angleDelta.y < 0)
					root.state.currentTab = Math.min(root.state.currentTab + 1, bar.count - 1);
				else if (event.angleDelta.y > 0)
					root.state.currentTab = Math.max(root.state.currentTab - 1, 0);
			}

			cursorShape: Qt.PointingHandCursor
			implicitHeight: icon.height + label.height
			implicitWidth: Math.max(icon.width, label.width)

			onPressed: event => {
				root.state.currentTab = tab.TabBar.index;

				const stateY = stateWrapper.y;
				rippleAnim.x = event.x;
				rippleAnim.y = event.y - stateY;

				const dist = (ox, oy) => ox * ox + oy * oy;
				rippleAnim.radius = Math.sqrt(Math.max(dist(event.x, event.y + stateY), dist(event.x, stateWrapper.height - event.y), dist(width - event.x, event.y + stateY), dist(width - event.x, stateWrapper.height - event.y)));

				rippleAnim.restart();
			}

			SequentialAnimation {
				id: rippleAnim

				property real radius
				property real x
				property real y

				PropertyAction {
					property: "x"
					target: ripple
					value: rippleAnim.x
				}

				PropertyAction {
					property: "y"
					target: ripple
					value: rippleAnim.y
				}

				PropertyAction {
					property: "opacity"
					target: ripple
					value: 0.08
				}

				Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
					from: 0
					properties: "implicitWidth,implicitHeight"
					target: ripple
					to: rippleAnim.radius * 2
				}

				Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
					easing.type: Easing.BezierSpline
					property: "opacity"
					target: ripple
					to: 0
				}
			}

			ClippingRectangle {
				id: stateWrapper

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				color: "transparent"
				implicitHeight: parent.height + 8 * 2
				radius: 8

				CustomRect {
					id: stateLayer

					anchors.fill: parent
					color: tab.current ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
					opacity: mouse.pressed ? 0.1 : tab.hovered ? 0.08 : 0

					Behavior on opacity {
						Anim {
						}
					}
				}

				CustomRect {
					id: ripple

					color: tab.current ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
					opacity: 0
					radius: 1000

					transform: Translate {
						x: -ripple.width / 2
						y: -ripple.height / 2
					}
				}
			}

			MaterialIcon {
				id: icon

				anchors.bottom: label.top
				anchors.horizontalCenter: parent.horizontalCenter
				color: tab.current ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
				fill: tab.current ? 1 : 0
				font.pointSize: 18
				text: tab.iconName

				Behavior on fill {
					Anim {
					}
				}
			}

			CustomText {
				id: label

				anchors.bottom: parent.bottom
				anchors.horizontalCenter: parent.horizontalCenter
				color: tab.current ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
				text: tab.text
			}
		}
	}
}
