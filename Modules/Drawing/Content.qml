pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components

Item {
	id: root

	readonly property var colors: ["#ef4444", "#f97316", "#eab308", "#22c55e", "#06b6d4", "#3b82f6", "#a855f7", "#ec4899", "#ffffff", "#000000"]
	required property Canvas drawing
	required property var visibilities

	function syncFromPenColor() {
		if (!drawing)
			return;

		if (!saturationSlider.pressed)
			saturationSlider.value = drawing.penColor.hsvSaturation;

		if (!brightnessSlider.pressed)
			brightnessSlider.value = drawing.penColor.hsvValue;
	}

	function updatePenColorFromHsv() {
		if (!drawing)
			return;

		drawing.penColor = Qt.hsva(huePicker.currentHue, saturationSlider.value, brightnessSlider.value, drawing.penColor.a);
	}

	implicitHeight: column.height + Appearance.padding.larger * 2
	implicitWidth: huePicker.implicitWidth + Appearance.padding.normal * 2

	Component.onCompleted: syncFromPenColor()

	Connections {
		function onPenColorChanged() {
			root.syncFromPenColor();
		}

		target: root.drawing
	}

	Column {
		id: column

		anchors.centerIn: parent
		spacing: 12

		ColorArcPicker {
			id: huePicker

			drawing: root.drawing
		}

		GradientSlider {
			id: saturationSlider

			brightness: brightnessSlider.value
			channel: "saturation"
			from: 0
			hue: huePicker.currentHue
			icon: "\ue40a"
			implicitHeight: 30
			implicitWidth: palette.width
			orientation: Qt.Horizontal
			to: 1

			onMoved: root.updatePenColorFromHsv()
		}

		GradientSlider {
			id: brightnessSlider

			channel: "brightness"
			from: 0
			hue: huePicker.currentHue
			icon: "\ue1ac"
			implicitHeight: 30
			implicitWidth: palette.width
			orientation: Qt.Horizontal
			saturation: saturationSlider.value
			to: 1

			onMoved: root.updatePenColorFromHsv()
		}

		GridLayout {
			id: palette

			anchors.left: parent.left
			anchors.right: parent.right
			columns: 5
			rowSpacing: 8
			rows: 2

			Repeater {
				model: root.colors

				delegate: Item {
					id: colorCircle

					required property color modelData
					readonly property bool selected: Qt.colorEqual(root.drawing.penColor, modelData)

					Layout.fillWidth: true
					height: 28

					CustomRect {
						anchors.centerIn: parent
						border.color: Qt.rgba(0, 0, 0, 0.25)
						border.width: Qt.colorEqual(modelData, "#ffffff") ? 1 : 0
						color: colorCircle.modelData
						height: 20
						radius: width / 2
						width: 20
					}

					CustomRect {
						anchors.centerIn: parent
						border.color: selected ? "#ffffff" : Qt.rgba(1, 1, 1, 0.28)
						border.width: selected ? 3 : 1
						color: "transparent"
						height: parent.height
						radius: width / 2
						width: parent.height

						StateLayer {
							onClicked: root.drawing.penColor = colorCircle.modelData
						}
					}
				}
			}
		}

		FilledSlider {
			from: 1
			icon: "border_color"
			implicitHeight: 30
			implicitWidth: palette.width
			multiplier: 1
			orientation: Qt.Horizontal
			to: 45
			value: root.drawing.penWidth

			onMoved: root.drawing.penWidth = value
		}
	}
}
