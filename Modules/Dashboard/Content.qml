pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components

Item {
	id: root

	readonly property real nonAnimHeight: view.implicitHeight + viewWrapper.anchors.margins * 2
	readonly property real nonAnimWidth: view.implicitWidth + viewWrapper.anchors.margins * 2
	required property PersistentProperties state
	required property PersistentProperties visibilities

	implicitHeight: nonAnimHeight
	implicitWidth: nonAnimWidth

	Behavior on implicitHeight {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}
	Behavior on implicitWidth {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	ClippingRectangle {
		id: viewWrapper

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: Appearance.padding.smaller
		anchors.right: parent.right
		anchors.top: parent.top
		color: "transparent"
		radius: 6

		Item {
			id: view

			readonly property int currentIndex: root.state.currentTab
			readonly property Item currentItem: row.children[currentIndex]

			anchors.fill: parent
			implicitHeight: currentItem.implicitHeight
			implicitWidth: currentItem.implicitWidth

			RowLayout {
				id: row

				Pane {
					index: 0

					sourceComponent: Dash {
						state: root.state
						visibilities: root.visibilities
					}
				}
			}
		}
	}

	component Pane: Loader {
		id: pane

		required property int index

		Layout.alignment: Qt.AlignTop

		Component.onCompleted: active = Qt.binding(() => {
			// Always keep current tab loaded
			if (pane.index === view.currentIndex)
				return true;
			const vx = Math.floor(view.visibleArea.xPosition * view.contentWidth);
			const vex = Math.floor(vx + view.visibleArea.widthRatio * view.contentWidth);
			return (vx >= x && vx <= x + implicitWidth) || (vex >= x && vex <= x + implicitWidth);
		})
	}
}
