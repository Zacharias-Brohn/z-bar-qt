import qs.Config
import QtQuick

CustomRect {
	id: root

	enum Type {
		Filled,
		Tonal,
		Text
	}

	property color activeColour: type === IconButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondary
	property color activeOnColour: type === IconButton.Filled ? DynamicColors.palette.m3onPrimary : type === IconButton.Tonal ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3primary
	property bool checked
	property bool disabled
	property color disabledColour: Qt.alpha(DynamicColors.palette.m3onSurface, 0.1)
	property color disabledOnColour: Qt.alpha(DynamicColors.palette.m3onSurface, 0.38)
	property alias font: label.font
	property alias icon: label.text
	property color inactiveColour: {
		if (!toggle && type === IconButton.Filled)
			return DynamicColors.palette.m3primary;
		return type === IconButton.Filled ? DynamicColors.tPalette.m3surfaceContainer : DynamicColors.palette.m3secondaryContainer;
	}
	property color inactiveOnColour: {
		if (!toggle && type === IconButton.Filled)
			return DynamicColors.palette.m3onPrimary;
		return type === IconButton.Tonal ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurfaceVariant;
	}
	property bool internalChecked
	property alias label: label
	property real padding: type === IconButton.Text ? 10 / 2 : 7
	property alias radiusAnim: radiusAnim
	property alias stateLayer: stateLayer
	property bool toggle
	property int type: IconButton.Filled

	signal clicked

	color: type === IconButton.Text ? "transparent" : disabled ? disabledColour : internalChecked ? activeColour : inactiveColour
	implicitHeight: label.implicitHeight + padding * 2
	implicitWidth: implicitHeight
	radius: internalChecked ? 6 : implicitHeight / 2 * Math.min(1, 1)

	Behavior on radius {
		Anim {
			id: radiusAnim

		}
	}

	onCheckedChanged: internalChecked = checked

	StateLayer {
		id: stateLayer

		function onClicked(): void {
			if (root.toggle)
				root.internalChecked = !root.internalChecked;
			root.clicked();
		}

		color: root.internalChecked ? root.activeOnColour : root.inactiveOnColour
		disabled: root.disabled
	}

	MaterialIcon {
		id: label

		anchors.centerIn: parent
		color: root.disabled ? root.disabledOnColour : root.internalChecked ? root.activeOnColour : root.inactiveOnColour
		fill: !root.toggle || root.internalChecked ? 1 : 0

		Behavior on fill {
			Anim {
			}
		}
	}
}
