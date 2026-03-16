pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

ColumnLayout {
	id: root

	required property string name
	required property var object
	required property string setting

	function addAction() {
		const list = [...root.object[root.setting]];
		list.push({
			name: "New Action",
			icon: "bolt",
			description: "",
			command: [],
			enabled: true,
			dangerous: false
		});
		root.object[root.setting] = list;
		Config.save();
	}

	function removeAction(index) {
		const list = [...root.object[root.setting]];
		list.splice(index, 1);
		root.object[root.setting] = list;
		Config.save();
	}

	function updateAction(index, key, value) {
		const list = [...root.object[root.setting]];
		const entry = list[index];
		entry[key] = value;
		list[index] = entry;
		root.object[root.setting] = list;
		Config.save();
	}

	Layout.fillWidth: true
	spacing: Appearance.spacing.smaller

	CustomText {
		Layout.fillWidth: true
		font.pointSize: Appearance.font.size.larger
		text: root.name
	}

	Repeater {
		model: [...root.object[root.setting]]

		CustomRect {
			required property int index
			required property var modelData

			Layout.fillWidth: true
			Layout.preferredHeight: layout.implicitHeight + Appearance.padding.normal * 2
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.normal

			ColumnLayout {
				id: layout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.normal
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: Appearance.spacing.small

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						font.pointSize: Appearance.font.size.larger
						text: modelData.name ?? qsTr("Action")
					}

					IconButton {
						font.pointSize: Appearance.font.size.large
						icon: "delete"
						type: IconButton.Tonal

						onClicked: root.removeAction(index)
					}
				}

				Separator {
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Name")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: 350
						color: DynamicColors.tPalette.m3surfaceContainerHigh
						radius: Appearance.rounding.full

						CustomTextField {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							anchors.rightMargin: Appearance.padding.normal
							text: modelData.name ?? ""

							onEditingFinished: root.updateAction(index, "name", text)
						}
					}
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Icon")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: 350
						color: DynamicColors.tPalette.m3surfaceContainerHigh
						radius: Appearance.rounding.full

						CustomTextField {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							anchors.rightMargin: Appearance.padding.normal
							text: modelData.icon ?? ""

							onEditingFinished: root.updateAction(index, "icon", text)
						}
					}
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Description")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: 350
						color: DynamicColors.tPalette.m3surfaceContainerHigh
						radius: Appearance.rounding.full

						CustomTextField {
							anchors.fill: parent
							anchors.leftMargin: Appearance.padding.normal
							anchors.rightMargin: Appearance.padding.normal
							text: modelData.description ?? ""

							onEditingFinished: root.updateAction(index, "description", text)
						}
					}
				}

				StringListEditor {
					Layout.fillWidth: true
					addLabel: qsTr("Add command argument")
					values: [...(modelData.command ?? [])]

					onListEdited: function (values) {
						root.updateAction(index, "command", values);
					}
				}

				Separator {
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Enabled")
					}

					CustomSwitch {
						checked: modelData.enabled ?? true

						onToggled: root.updateAction(index, "enabled", checked)
					}
				}

				Separator {
				}

				RowLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Dangerous")
					}

					CustomSwitch {
						checked: modelData.dangerous ?? false

						onToggled: root.updateAction(index, "dangerous", checked)
					}
				}
			}
		}
	}

	RowLayout {
		Layout.fillWidth: true

		IconButton {
			font.pointSize: Appearance.font.size.large
			icon: "add"

			onClicked: root.addAction()
		}

		CustomText {
			Layout.fillWidth: true
			text: qsTr("Add action")
		}
	}
}
