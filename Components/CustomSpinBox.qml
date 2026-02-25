pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config

RowLayout {
	id: root

	property string displayText: root.value.toString()
	property bool isEditing: false
	property real max: Infinity
	property real min: -Infinity
	property alias repeatRate: timer.interval
	property real step: 1
	property real value

	signal valueModified(value: real)

	spacing: Appearance.spacing.small

	onValueChanged: {
		if (!root.isEditing) {
			root.displayText = root.value.toString();
		}
	}

	CustomTextField {
		id: textField

		inputMethodHints: Qt.ImhFormattedNumbersOnly
		leftPadding: Appearance.padding.normal
		padding: Appearance.padding.small
		rightPadding: Appearance.padding.normal
		text: root.isEditing ? text : root.displayText

		background: CustomRect {
			color: DynamicColors.tPalette.m3surfaceContainerHigh
			implicitWidth: 100
			radius: Appearance.rounding.small
		}
		validator: DoubleValidator {
			bottom: root.min
			decimals: root.step < 1 ? Math.max(1, Math.ceil(-Math.log10(root.step))) : 0
			top: root.max
		}

		onAccepted: {
			const numValue = parseFloat(text);
			if (!isNaN(numValue)) {
				const clampedValue = Math.max(root.min, Math.min(root.max, numValue));
				root.value = clampedValue;
				root.displayText = clampedValue.toString();
				root.valueModified(clampedValue);
			} else {
				text = root.displayText;
			}
			root.isEditing = false;
		}
		onActiveFocusChanged: {
			if (activeFocus) {
				root.isEditing = true;
			} else {
				root.isEditing = false;
				root.displayText = root.value.toString();
			}
		}
		onEditingFinished: {
			if (text !== root.displayText) {
				const numValue = parseFloat(text);
				if (!isNaN(numValue)) {
					const clampedValue = Math.max(root.min, Math.min(root.max, numValue));
					root.value = clampedValue;
					root.displayText = clampedValue.toString();
					root.valueModified(clampedValue);
				} else {
					text = root.displayText;
				}
			}
			root.isEditing = false;
		}
	}

	CustomRect {
		color: DynamicColors.palette.m3primary
		implicitHeight: upIcon.implicitHeight + Appearance.padding.small * 2
		implicitWidth: implicitHeight
		radius: Appearance.rounding.small

		StateLayer {
			id: upState

			function onClicked(): void {
				let newValue = Math.min(root.max, root.value + root.step);
				// Round to avoid floating point precision errors
				const decimals = root.step < 1 ? Math.max(1, Math.ceil(-Math.log10(root.step))) : 0;
				newValue = Math.round(newValue * Math.pow(10, decimals)) / Math.pow(10, decimals);
				root.value = newValue;
				root.displayText = newValue.toString();
				root.valueModified(newValue);
			}

			color: DynamicColors.palette.m3onPrimary

			onPressAndHold: timer.start()
			onReleased: timer.stop()
		}

		MaterialIcon {
			id: upIcon

			anchors.centerIn: parent
			color: DynamicColors.palette.m3onPrimary
			text: "keyboard_arrow_up"
		}
	}

	CustomRect {
		color: DynamicColors.palette.m3primary
		implicitHeight: downIcon.implicitHeight + Appearance.padding.small * 2
		implicitWidth: implicitHeight
		radius: Appearance.rounding.small

		StateLayer {
			id: downState

			function onClicked(): void {
				let newValue = Math.max(root.min, root.value - root.step);
				// Round to avoid floating point precision errors
				const decimals = root.step < 1 ? Math.max(1, Math.ceil(-Math.log10(root.step))) : 0;
				newValue = Math.round(newValue * Math.pow(10, decimals)) / Math.pow(10, decimals);
				root.value = newValue;
				root.displayText = newValue.toString();
				root.valueModified(newValue);
			}

			color: DynamicColors.palette.m3onPrimary

			onPressAndHold: timer.start()
			onReleased: timer.stop()
		}

		MaterialIcon {
			id: downIcon

			anchors.centerIn: parent
			color: DynamicColors.palette.m3onPrimary
			text: "keyboard_arrow_down"
		}
	}

	Timer {
		id: timer

		interval: 100
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			if (upState.pressed)
				upState.onClicked();
			else if (downState.pressed)
				downState.onClicked();
		}
	}
}
