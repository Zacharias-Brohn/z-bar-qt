pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ColumnLayout {
	id: root

	property string addLabel: qsTr("Add entry")
	property var values: []

	signal listEdited(var values)

	function addValue() {
		const list = [...root.values];
		list.push("");
		root.listEdited(list);
	}

	function removeValue(index) {
		const list = [...root.values];
		list.splice(index, 1);
		root.listEdited(list);
	}

	function updateValue(index, value) {
		const list = [...root.values];
		list[index] = value;
		root.listEdited(list);
	}

	Layout.fillWidth: true
	spacing: Appearance.spacing.smaller

	Repeater {
		model: [...root.values]

		Item {
			required property int index
			required property var modelData

			Layout.fillWidth: true
			Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

			CustomRect {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.topMargin: -(Appearance.spacing.smaller / 2)
				color: DynamicColors.tPalette.m3outlineVariant
				implicitHeight: 1
				visible: index !== 0
			}

			RowLayout {
				id: row

				anchors.left: parent.left
				anchors.margins: Appearance.padding.small
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter

				CustomRect {
					Layout.fillWidth: true
					Layout.preferredHeight: 33
					color: DynamicColors.tPalette.m3surfaceContainerHigh
					radius: Appearance.rounding.full

					CustomTextField {
						anchors.fill: parent
						anchors.leftMargin: Appearance.padding.normal
						anchors.rightMargin: Appearance.padding.normal
						text: String(modelData ?? "")

						onEditingFinished: root.updateValue(index, text)
					}
				}

				IconButton {
					font.pointSize: Appearance.font.size.large
					icon: "delete"
					type: IconButton.Tonal

					onClicked: root.removeValue(index)
				}
			}
		}
	}

	RowLayout {
		Layout.fillWidth: true

		IconButton {
			font.pointSize: Appearance.font.size.large
			icon: "add"

			onClicked: root.addValue()
		}

		CustomText {
			Layout.fillWidth: true
			text: root.addLabel
		}
	}
}
