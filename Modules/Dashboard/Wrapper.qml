pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	readonly property PersistentProperties dashState: PersistentProperties {
		property date currentDate: new Date()
		property int currentTab

		reloadableId: "dashboardState"
	}
	readonly property real nonAnimHeight: state === "visible" ? (content.item?.nonAnimHeight ?? 0) : 0
	required property PersistentProperties visibilities

	implicitHeight: 0
	implicitWidth: content.implicitWidth
	visible: height > 0

	states: State {
		name: "visible"
		when: root.visibilities.dashboard && Config.dashboard.enabled

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
			content.active = Qt.binding(() => (root.visibilities.dashboard && Config.dashboard.enabled) || root.visible);
			content.visible = true;
		}
	}

	Loader {
		id: content

		active: true
		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		visible: false

		sourceComponent: Content {
			state: root.dashState
			visibilities: root.visibilities
		}
	}
}
