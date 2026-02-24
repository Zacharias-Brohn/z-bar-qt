import qs.Config
import QtQuick
import QtQuick.Templates

ScrollBar {
	id: root

	property bool _updatingFromFlickable: false
	property bool _updatingFromUser: false
	property bool animating
	required property Flickable flickable
	property real nonAnimPosition
	property bool shouldBeActive

	implicitWidth: 8

	contentItem: CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		color: DynamicColors.palette.m3secondary
		opacity: {
			if (root.size === 1)
				return 0;
			if (fullMouse.pressed)
				return 1;
			if (mouse.containsMouse)
				return 0.8;
			if (root.policy === ScrollBar.AlwaysOn || root.shouldBeActive)
				return 0.6;
			return 0;
		}
		radius: 1000

		Behavior on opacity {
			Anim {
			}
		}

		MouseArea {
			id: mouse

			acceptedButtons: Qt.NoButton
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true
		}
	}
	Behavior on position {
		enabled: !fullMouse.pressed

		Anim {
		}
	}

	Component.onCompleted: {
		if (flickable) {
			const contentHeight = flickable.contentHeight;
			const height = flickable.height;
			if (contentHeight > height) {
				nonAnimPosition = Math.max(0, Math.min(1, flickable.contentY / (contentHeight - height)));
			}
		}
	}
	onHoveredChanged: {
		if (hovered)
			shouldBeActive = true;
		else
			shouldBeActive = flickable.moving;
	}

	// Sync nonAnimPosition with Qt's automatic position binding
	onPositionChanged: {
		if (_updatingFromUser) {
			_updatingFromUser = false;
			return;
		}
		if (position === nonAnimPosition) {
			animating = false;
			return;
		}
		if (!animating && !_updatingFromFlickable && !fullMouse.pressed) {
			nonAnimPosition = position;
		}
	}

	// Sync nonAnimPosition with flickable when not animating
	Connections {
		function onContentYChanged() {
			if (!animating && !fullMouse.pressed) {
				_updatingFromFlickable = true;
				const contentHeight = flickable.contentHeight;
				const height = flickable.height;
				if (contentHeight > height) {
					nonAnimPosition = Math.max(0, Math.min(1, flickable.contentY / (contentHeight - height)));
				} else {
					nonAnimPosition = 0;
				}
				_updatingFromFlickable = false;
			}
		}

		target: flickable
	}

	Connections {
		function onMovingChanged(): void {
			if (root.flickable.moving)
				root.shouldBeActive = true;
			else
				hideDelay.restart();
		}

		target: root.flickable
	}

	Timer {
		id: hideDelay

		interval: 600

		onTriggered: root.shouldBeActive = root.flickable.moving || root.hovered
	}

	CustomMouseArea {
		id: fullMouse

		function onWheel(event: WheelEvent): void {
			root.animating = true;
			root._updatingFromUser = true;
			let newPos = root.nonAnimPosition;
			if (event.angleDelta.y > 0)
				newPos = Math.max(0, root.nonAnimPosition - 0.1);
			else if (event.angleDelta.y < 0)
				newPos = Math.min(1 - root.size, root.nonAnimPosition + 0.1);
			root.nonAnimPosition = newPos;
			// Update flickable position
			// Map scrollbar position [0, 1-size] to contentY [0, maxContentY]
			if (root.flickable) {
				const contentHeight = root.flickable.contentHeight;
				const height = root.flickable.height;
				if (contentHeight > height) {
					const maxContentY = contentHeight - height;
					const maxPos = 1 - root.size;
					const contentY = maxPos > 0 ? (newPos / maxPos) * maxContentY : 0;
					root.flickable.contentY = Math.max(0, Math.min(maxContentY, contentY));
				}
			}
		}

		anchors.fill: parent
		preventStealing: true

		onPositionChanged: event => {
			root._updatingFromUser = true;
			const newPos = Math.max(0, Math.min(1 - root.size, event.y / root.height - root.size / 2));
			root.nonAnimPosition = newPos;
			// Update flickable position
			// Map scrollbar position [0, 1-size] to contentY [0, maxContentY]
			if (root.flickable) {
				const contentHeight = root.flickable.contentHeight;
				const height = root.flickable.height;
				if (contentHeight > height) {
					const maxContentY = contentHeight - height;
					const maxPos = 1 - root.size;
					const contentY = maxPos > 0 ? (newPos / maxPos) * maxContentY : 0;
					root.flickable.contentY = Math.max(0, Math.min(maxContentY, contentY));
				}
			}
		}
		onPressed: event => {
			root.animating = true;
			root._updatingFromUser = true;
			const newPos = Math.max(0, Math.min(1 - root.size, event.y / root.height - root.size / 2));
			root.nonAnimPosition = newPos;
			// Update flickable position
			// Map scrollbar position [0, 1-size] to contentY [0, maxContentY]
			if (root.flickable) {
				const contentHeight = root.flickable.contentHeight;
				const height = root.flickable.height;
				if (contentHeight > height) {
					const maxContentY = contentHeight - height;
					const maxPos = 1 - root.size;
					const contentY = maxPos > 0 ? (newPos / maxPos) * maxContentY : 0;
					root.flickable.contentY = Math.max(0, Math.min(maxContentY, contentY));
				}
			}
		}
	}
}
