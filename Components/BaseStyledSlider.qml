import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
	id: root

	property color color: DynamicColors.palette.m3secondary
	required property string icon
	property bool initialized: false
	readonly property bool isHorizontal: orientation === Qt.Horizontal
	readonly property bool isVertical: orientation === Qt.Vertical
	property real multiplier: 100
	property real oldValue

	// Wrapper components can inject their own track visuals here.
	property Component trackContent

	// Keep current behavior for existing usages.
	orientation: Qt.Vertical

	background: CustomRect {
		id: groove

		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)
		height: root.availableHeight
		radius: Appearance.rounding.full
		width: root.availableWidth
		x: root.leftPadding
		y: root.topPadding

		Loader {
			id: trackLoader

			anchors.fill: parent
			sourceComponent: root.trackContent

			onLoaded: {
				if (!item)
					return;

				item.rootSlider = root;
				item.groove = groove;
				item.handleItem = handle;
			}
		}
	}
	handle: Item {
		id: handle

		property alias moving: icon.moving

		implicitHeight: Math.min(root.width, root.height)
		implicitWidth: Math.min(root.width, root.height)
		x: root.isHorizontal ? root.leftPadding + root.visualPosition * (root.availableWidth - width) : root.leftPadding + (root.availableWidth - width) / 2
		y: root.isVertical ? root.topPadding + root.visualPosition * (root.availableHeight - height) : root.topPadding + (root.availableHeight - height) / 2

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
					value: Math.round(root.value * root.multiplier)
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
			oldValue = value;
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
