pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import Quickshell
import QtQuick

Item {
	id: root

	required property Item popouts
	readonly property PersistentProperties props: PersistentProperties {
		property string recordingConfirmDelete
		property bool recordingListExpanded: false
		property string recordingMode

		reloadableId: "utilities"
	}
	readonly property bool shouldBeActive: visibilities.sidebar
	required property Item sidebar
	required property var visibilities

	implicitHeight: 0
	implicitWidth: sidebar.visible ? sidebar.width : Config.utilities.sizes.width
	visible: height > 0

	states: State {
		name: "visible"
		when: root.shouldBeActive

		PropertyChanges {
			root.implicitHeight: content.implicitHeight + 8 * 2
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

		interval: 1000
		running: true

		onTriggered: {
			content.active = Qt.binding(() => root.shouldBeActive || root.visible);
			content.visible = true;
		}
	}

	Loader {
		id: content

		active: true
		anchors.left: parent.left
		anchors.margins: 8
		anchors.top: parent.top
		visible: false

		sourceComponent: Content {
			implicitWidth: root.implicitWidth - 8 * 2
			popouts: root.popouts
			props: root.props
			visibilities: root.visibilities
		}
	}
}
