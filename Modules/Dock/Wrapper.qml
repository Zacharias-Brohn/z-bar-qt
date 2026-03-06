pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	property int contentHeight
	required property var panels
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.dock
	required property PersistentProperties visibilities

	implicitHeight: 0
	implicitWidth: content.implicitWidth
	visible: height > 0

	onShouldBeActiveChanged: {
		if (shouldBeActive) {
			timer.stop();
			hideAnim.stop();
			showAnim.start();
		} else {
			showAnim.stop();
			hideAnim.start();
		}
	}

	SequentialAnimation {
		id: showAnim

		Anim {
			duration: Appearance.anim.durations.small
			easing.bezierCurve: Appearance.anim.curves.expressiveEffects
			property: "implicitHeight"
			target: root
			to: root.contentHeight
		}

		ScriptAction {
			script: root.implicitHeight = Qt.binding(() => content.implicitHeight)
		}
	}

	SequentialAnimation {
		id: hideAnim

		ScriptAction {
			script: root.implicitHeight = root.implicitHeight
		}

		Anim {
			easing.bezierCurve: Appearance.anim.curves.expressiveEffects
			property: "implicitHeight"
			target: root
			to: 0
		}
	}

	Timer {
		id: timer

		interval: Appearance.anim.durations.small

		onRunningChanged: {
			if (running && !root.shouldBeActive) {
				content.visible = false;
				content.active = true;
			} else {
				content.active = Qt.binding(() => root.shouldBeActive || root.visible);
				content.visible = true;
				if (showAnim.running) {
					showAnim.stop();
					showAnim.start();
				}
			}
		}
	}

	Loader {
		id: content

		active: false
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		visible: false

		sourceComponent: Content {
			panels: root.panels
			visibilities: root.visibilities

			Component.onCompleted: root.contentHeight = implicitHeight
		}

		Component.onCompleted: timer.start()
	}
}
