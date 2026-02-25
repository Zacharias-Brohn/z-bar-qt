import QtQuick
import qs.Config

Item {
	id: root

	property color color: DynamicColors.palette.m3onSurface
	property int fadeStrengthAnimMs: 180
	property real fadeStrengthIdle: 0.0
	property real fadeStrengthMoving: 1.0
	property alias font: elideText.font
	property int gap: 40
	property alias horizontalAlignment: elideText.horizontalAlignment
	property bool leftFadeEnabled: false
	property real leftFadeStrength: overflowing && leftFadeEnabled ? fadeStrengthMoving : fadeStrengthIdle
	property int leftFadeWidth: 28
	property bool marqueeEnabled: true
	readonly property bool overflowing: metrics.width > root.width
	property int pauseMs: 1200
	property real pixelsPerSecond: 40
	property real rightFadeStrength: overflowing ? fadeStrengthMoving : fadeStrengthIdle
	property int rightFadeWidth: 28
	property bool sliding: false
	property alias text: elideText.text

	function durationForDistance(px): int {
		return Math.max(1, Math.round(Math.abs(px) / root.pixelsPerSecond * 1000));
	}

	clip: true
	implicitHeight: elideText.implicitHeight

	Behavior on leftFadeStrength {
		Anim {
		}
	}
	Behavior on rightFadeStrength {
		Anim {
		}
	}

	onTextChanged: strip.x = 0
	onVisibleChanged: if (!visible)
		strip.x = 0
	onWidthChanged: strip.x = 0

	TextMetrics {
		id: metrics

		font: elideText.font
		text: elideText.text
	}

	CustomText {
		id: elideText

		anchors.verticalCenter: parent.verticalCenter
		color: root.color
		elide: Text.ElideRight
		visible: !root.overflowing
		width: root.width
	}

	Item {
		id: marqueeViewport

		anchors.fill: parent
		clip: true
		layer.enabled: true
		visible: root.overflowing

		layer.effect: OpacityMask {
			maskSource: rightFadeMask
		}

		Item {
			id: strip

			anchors.verticalCenter: parent.verticalCenter
			height: t1.implicitHeight
			width: t1.width + root.gap + t2.width
			x: 0

			CustomText {
				id: t1

				color: root.color
				text: elideText.text
			}

			CustomText {
				id: t2

				color: root.color
				text: t1.text
				x: t1.width + root.gap
			}
		}

		SequentialAnimation {
			id: marqueeAnim

			loops: Animation.Infinite
			running: root.marqueeEnabled && root.overflowing && root.visible

			ScriptAction {
				script: {
					strip.x = 0;
					root.sliding = false;
					root.leftFadeEnabled = false;
				}
			}

			PauseAnimation {
				duration: root.pauseMs
			}

			ScriptAction {
				script: {
					root.sliding = true;
					root.leftFadeEnabled = true;
				}
			}

			Anim {
				duration: root.durationForDistance(t1.width)
				easing.bezierCurve: Easing.Linear
				easing.type: Easing.Linear
				from: 0
				property: "x"
				target: strip
				to: -t1.width
			}

			ScriptAction {
				script: {
					root.leftFadeEnabled = false;
				}
			}

			Anim {
				duration: root.durationForDistance(root.gap)
				easing.bezierCurve: Easing.Linear
				easing.type: Easing.Linear
				from: -t1.width
				property: "x"
				target: strip
				to: -(t1.width + root.gap)
			}

			ScriptAction {
				script: {
					root.sliding = false;
					strip.x = 0;
				}
			}
		}
	}

	Rectangle {
		id: rightFadeMask

		readonly property real fadeStartPos: {
			const w = Math.max(1, width);
			return Math.max(0, Math.min(1, (w - root.rightFadeWidth) / w));
		}
		readonly property real leftFadeEndPos: {
			const w = Math.max(1, width);
			return Math.max(0, Math.min(1, root.leftFadeWidth / w));
		}

		anchors.fill: marqueeViewport
		layer.enabled: true
		visible: false

		gradient: Gradient {
			orientation: Gradient.Horizontal

			GradientStop {
				color: Qt.rgba(1, 1, 1, 1.0 - root.leftFadeStrength)
				position: 0.0
			}

			GradientStop {
				color: Qt.rgba(1, 1, 1, 1.0)
				position: rightFadeMask.leftFadeEndPos
			}

			GradientStop {
				color: Qt.rgba(1, 1, 1, 1.0)
				position: rightFadeMask.fadeStartPos
			}

			GradientStop {
				color: Qt.rgba(1, 1, 1, 1.0 - root.rightFadeStrength)
				position: 1.0
			}
		}
	}
}
