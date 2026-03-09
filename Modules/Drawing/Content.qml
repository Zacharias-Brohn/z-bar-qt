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

	implicitHeight: huePicker.implicitHeight + 12 + palette.implicitHeight + Appearance.padding.normal * 2
	implicitWidth: huePicker.implicitWidth + Appearance.padding.normal * 2

	Column {
		anchors.centerIn: parent
		spacing: 12

		ColorArcPicker {
			id: huePicker

			drawing: root.drawing
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
					required property color modelData
					readonly property bool selected: Qt.colorEqual(root.drawing.penColor, modelData)

					Layout.fillWidth: true
					height: 28

					CustomRect {
						anchors.centerIn: parent
						border.color: selected ? "#ffffff" : Qt.rgba(1, 1, 1, 0.28)
						border.width: selected ? 3 : 1
						color: "transparent"
						height: parent.height
						radius: width / 2
						width: parent.height
					}

					CustomRect {
						anchors.centerIn: parent
						border.color: Qt.rgba(0, 0, 0, 0.25)
						border.width: Qt.colorEqual(modelData, "#ffffff") ? 1 : 0
						color: modelData
						height: 20
						radius: width / 2
						width: 20
					}

					MouseArea {
						anchors.fill: parent

						onClicked: root.drawing.penColor = parent.modelData
					}
				}
			}
		}
	}
}
