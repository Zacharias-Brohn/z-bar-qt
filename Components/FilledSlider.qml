import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
	id: root

	property color color: DynamicColors.palette.m3secondary
	required property string icon
	property bool initialized
	property real oldValue

	orientation: Qt.Vertical

	background: CustomRect {
		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)
		radius: Appearance.rounding.full

		CustomRect {
			anchors.left: parent.left
			anchors.right: parent.right
			color: root.color
			implicitHeight: parent.height - y
			radius: parent.radius
			y: root.handle.y
		}
	}
	handle: Item {
		id: handle

		property alias moving: icon.moving

		implicitHeight: root.width
		implicitWidth: root.width
		y: root.visualPosition * (root.availableHeight - height)

		Elevation {
			anchors.fill: parent
			level: handleInteraction.containsMouse ? 2 : 1
			radius: rect.radius
		}

		CustomRect {
			id: rect

			anchors.fill: parent
			color: DynamicColors.palette.m3inverseSurface
			radius: Appearance.rounding.full

			MouseArea {
				id: handleInteraction

				acceptedButtons: Qt.NoButton
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true
			}

			MaterialIcon {
				id: icon

				property bool moving

				function update(): void {
					animate = !moving;
					binding.when = moving;
					font.pointSize = moving ? Appearance.font.size.small : Appearance.font.size.larger;
					font.family = moving ? Appearance.font.family.sans : Appearance.font.family.material;
				}

				anchors.centerIn: parent
				color: DynamicColors.palette.m3inverseOnSurface
				text: root.icon

				onMovingChanged: anim.restart()

				Binding {
					id: binding

					property: "text"
					target: icon
					value: Math.round(root.value * 100)
					when: false
				}

				SequentialAnimation {
					id: anim

					Anim {
						duration: Appearance.anim.durations.normal / 2
						easing.bezierCurve: Appearance.anim.curves.standardAccel
						property: "scale"
						target: icon
						to: 0
					}

					ScriptAction {
						script: icon.update()
					}

					Anim {
						duration: Appearance.anim.durations.normal / 2
						easing.bezierCurve: Appearance.anim.curves.standardDecel
						property: "scale"
						target: icon
						to: 1
					}
				}
			}
		}
	}
	Behavior on value {
		Anim {
			duration: Appearance.anim.durations.large
		}
	}

	onPressedChanged: handle.moving = pressed
	onValueChanged: {
		if (!initialized) {
			initialized = true;
			return;
		}
		if (Math.abs(value - oldValue) < 0.01)
			return;
		oldValue = value;
		handle.moving = true;
		stateChangeDelay.restart();
	}

	Timer {
		id: stateChangeDelay

		interval: 500

		onTriggered: {
			if (!root.pressed)
				handle.moving = false;
		}
	}
}
