pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

Item {
	id: root

	property real brightness
	property bool hovered
	readonly property Brightness.Monitor monitor: Brightness.getMonitorForScreen(root.screen)
	property bool muted
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.osd && Config.osd.enabled && !(visibilities.utilities && Config.utilities.enabled)
	property bool sourceMuted
	property real sourceVolume
	required property var visibilities
	property real volume

	function show(): void {
		visibilities.osd = true;
		timer.restart();
	}

	implicitHeight: content.implicitHeight
	implicitWidth: 0
	visible: width > 0

	states: State {
		name: "visible"
		when: root.shouldBeActive

		PropertyChanges {
			root.implicitWidth: content.implicitWidth
		}
	}
	transitions: [
		Transition {
			from: ""
			to: "visible"

			Anim {
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitWidth"
				target: root
			}
		},
		Transition {
			from: "visible"
			to: ""

			Anim {
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitWidth"
				target: root
			}
		}
	]

	Component.onCompleted: {
		volume = Audio.volume;
		muted = Audio.muted;
		sourceVolume = Audio.sourceVolume;
		sourceMuted = Audio.sourceMuted;
		brightness = root.monitor?.brightness ?? 0;
	}

	Connections {
		function onMutedChanged(): void {
			root.show();
			root.muted = Audio.muted;
		}

		function onSourceMutedChanged(): void {
			root.show();
			root.sourceMuted = Audio.sourceMuted;
		}

		function onSourceVolumeChanged(): void {
			root.show();
			root.sourceVolume = Audio.sourceVolume;
		}

		function onVolumeChanged(): void {
			root.show();
			root.volume = Audio.volume;
		}

		target: Audio
	}

	Connections {
		function onBrightnessChanged(): void {
			root.show();
			root.brightness = root.monitor?.brightness ?? 0;
		}

		target: root.monitor
	}

	Timer {
		id: timer

		interval: Config.osd.hideDelay

		onTriggered: {
			if (!root.hovered)
				root.visibilities.osd = false;
		}
	}

	Loader {
		id: content

		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter

		sourceComponent: Content {
			brightness: root.brightness
			monitor: root.monitor
			muted: root.muted
			sourceMuted: root.sourceMuted
			sourceVolume: root.sourceVolume
			visibilities: root.visibilities
			volume: root.volume
		}

		Component.onCompleted: active = Qt.binding(() => root.shouldBeActive || root.visible)
	}
}
