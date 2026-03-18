import QtQuick
import QtQuick.Effects
import qs.Config

Elevation {
	id: root

	required property int currentIndex
	property bool expanded
	required property int from
	property color insideTextColor: DynamicColors.palette.m3onPrimary
	property int itemHeight
	property int listHeight: 200
	property color outsideTextColor: DynamicColors.palette.m3onSurfaceVariant
	readonly property var spinnerModel: root.range(root.from, root.to)
	required property int to
	property Item triggerItem

	signal itemSelected(item: int)

	function range(first, last) {
		let out = [];
		for (let i = first; i <= last; ++i)
			out.push(i);
		return out;
	}

	implicitHeight: root.expanded ? view.implicitHeight : 0
	level: root.expanded ? 2 : 0
	radius: itemHeight / 2
	visible: implicitHeight > 0

	Behavior on implicitHeight {
		Anim {
		}
	}

	onExpandedChanged: {
		if (!root.expanded)
			root.itemSelected(view.currentIndex + 1);
	}

	Component {
		id: spinnerDelegate

		Item {
			id: wrapper

			readonly property color delegateTextColor: wrapper.PathView.view ? wrapper.PathView.view.delegateTextColor : "white"
			required property var modelData

			height: root.itemHeight
			opacity: wrapper.PathView.itemOpacity
			visible: wrapper.PathView.onPath
			width: wrapper.PathView.view ? wrapper.PathView.view.width : 0
			z: wrapper.PathView.isCurrentItem ? 100 : Math.round(wrapper.PathView.itemScale * 100)

			CustomText {
				anchors.centerIn: parent
				color: wrapper.delegateTextColor
				font.pointSize: Appearance.font.size.large
				text: wrapper.modelData
			}
		}
	}

	CustomClippingRect {
		anchors.fill: parent
		color: DynamicColors.palette.m3surfaceContainer
		radius: parent.radius

		// Main visible spinner: normal/outside text color
		PathView {
			id: view

			property color delegateTextColor: root.outsideTextColor

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			clip: true
			currentIndex: root.currentIndex - 1
			delegate: spinnerDelegate
			dragMargin: width
			highlightRangeMode: PathView.StrictlyEnforceRange
			implicitHeight: root.listHeight
			model: root.spinnerModel
			pathItemCount: 7
			preferredHighlightBegin: 0.5
			preferredHighlightEnd: 0.5
			snapMode: PathView.SnapToItem

			path: PathMenu {
				viewHeight: view.height
				viewWidth: view.width
			}
		}

		// The selection rectangle itself
		CustomRect {
			id: selectionRect

			anchors.verticalCenter: parent.verticalCenter
			color: DynamicColors.palette.m3primary
			height: root.itemHeight
			radius: root.itemHeight / 2
			width: parent.width
			z: 2
		}

		// Hidden source: same PathView, but with the "inside selection" text color
		Item {
			id: selectedTextSource

			anchors.fill: parent
			layer.enabled: true
			visible: false

			PathView {
				id: selectedTextView

				property color delegateTextColor: root.insideTextColor

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				clip: true
				currentIndex: view.currentIndex
				delegate: spinnerDelegate
				dragMargin: view.dragMargin
				highlightRangeMode: view.highlightRangeMode
				implicitHeight: root.listHeight
				interactive: false
				model: view.model

				// Keep this PathView visually locked to the real one
				offset: view.offset
				pathItemCount: view.pathItemCount
				preferredHighlightBegin: view.preferredHighlightBegin
				preferredHighlightEnd: view.preferredHighlightEnd
				snapMode: view.snapMode

				path: PathMenu {
					viewHeight: selectedTextView.height
					viewWidth: selectedTextView.width
				}
			}
		}

		// Mask matching the selection rectangle
		Item {
			id: selectionMask

			anchors.fill: parent
			layer.enabled: true
			visible: false

			CustomRect {
				color: "white"
				height: selectionRect.height
				radius: selectionRect.radius
				width: selectionRect.width
				x: selectionRect.x
				y: selectionRect.y
			}
		}

		// Only show the "inside selection" text where the mask exists
		MultiEffect {
			anchors.fill: selectedTextSource
			maskEnabled: true
			maskInverted: false
			maskSource: selectionMask
			source: selectedTextSource
			z: 3
		}
	}
}
