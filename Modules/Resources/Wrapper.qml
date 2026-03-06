pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	readonly property real nonAnimHeight: state === "visible" ? (content.item?.nonAnimHeight ?? 0) : 0
	required property PersistentProperties visibilities

	implicitHeight: 0
	implicitWidth: content.implicitWidth
	visible: height > 0

	states: State {
		name: "visible"
		when: root.visibilities.resources

		PropertyChanges {
			root.implicitHeight: content.implicitHeight
		}
	}
	transitions: [
		Transition {
			from: ""
			to: "visible"

			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitHeight"
				target: root
			}
		},
		Transition {
			from: "visible"
			to: ""

			Anim {
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitHeight"
				target: root
			}
		}
	]

	onStateChanged: {
		if (state === "visible" && timer.running) {
			timer.triggered();
			timer.stop();
		}
	}

	Timer {
		id: timer

		interval: Appearance.anim.durations.extraLarge
		running: true

		onTriggered: {
			content.active = Qt.binding(() => (root.visibilities.resources) || root.visible);
			content.visible = true;
		}
	}

	CustomClippingRect {
		anchors.fill: parent

		Loader {
			id: content

			active: true
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			visible: false

			sourceComponent: Content {
				padding: Appearance.padding.normal
				visibilities: root.visibilities
			}
		}
	}
}
