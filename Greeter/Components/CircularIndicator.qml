import qs.Config
import ZShell.Internal
import QtQuick
import QtQuick.Templates

BusyIndicator {
	id: root

	enum AnimState {
		Stopped,
		Running,
		Completing
	}
	enum AnimType {
		Advance = 0,
		Retreat
	}

	property int animState
	property color bgColour: DynamicColors.palette.m3secondaryContainer
	property color fgColour: DynamicColors.palette.m3primary
	property real implicitSize: Appearance.font.size.normal * 3
	property real internalStrokeWidth: strokeWidth
	readonly property alias progress: manager.progress
	property real strokeWidth: Appearance.padding.small * 0.8
	property alias type: manager.indeterminateAnimationType

	implicitHeight: implicitSize
	implicitWidth: implicitSize
	padding: 0

	contentItem: CircularProgress {
		anchors.fill: parent
		bgColour: root.bgColour
		fgColour: root.fgColour
		padding: root.padding
		rotation: manager.rotation
		startAngle: manager.startFraction * 360
		strokeWidth: root.internalStrokeWidth
		value: manager.endFraction - manager.startFraction
	}
	states: State {
		name: "stopped"
		when: !root.running

		PropertyChanges {
			root.internalStrokeWidth: root.strokeWidth / 3
			root.opacity: 0
		}
	}
	transitions: Transition {
		Anim {
			duration: manager.completeEndDuration * Appearance.anim.durations.scale
			properties: "opacity,internalStrokeWidth"
		}
	}

	Component.onCompleted: {
		if (running) {
			running = false;
			running = true;
		}
	}
	onRunningChanged: {
		if (running) {
			manager.completeEndProgress = 0;
			animState = CircularIndicator.Running;
		} else {
			if (animState == CircularIndicator.Running)
				animState = CircularIndicator.Completing;
		}
	}

	CircularIndicatorManager {
		id: manager

	}

	NumberAnimation {
		duration: manager.duration * Appearance.anim.durations.scale
		from: 0
		loops: Animation.Infinite
		property: "progress"
		running: root.animState !== CircularIndicator.Stopped
		target: manager
		to: 1
	}

	NumberAnimation {
		duration: manager.completeEndDuration * Appearance.anim.durations.scale
		from: 0
		property: "completeEndProgress"
		running: root.animState === CircularIndicator.Completing
		target: manager
		to: 1

		onFinished: {
			if (root.animState === CircularIndicator.Completing)
				root.animState = CircularIndicator.Stopped;
		}
	}
}
