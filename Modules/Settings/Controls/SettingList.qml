import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property int index
	required property var modelData

	signal addActiveActionRequested
	signal fieldEdited(string key, var value)

	Layout.fillWidth: true
	Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

	CustomRect {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.topMargin: -(Appearance.spacing.smaller / 2)
		color: DynamicColors.tPalette.m3outlineVariant
		implicitHeight: 1
		visible: root.index !== 0
	}

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.large

		Item {
			id: nameCell

			property string draftName: ""
			property bool editing: false

			function beginEdit() {
				draftName = root.modelData.name ?? "";
				editing = true;
				nameEditor.forceActiveFocus();
			}

			function cancelEdit() {
				draftName = root.modelData.name ?? "";
				editing = false;
			}

			function commitEdit() {
				editing = false;

				if (draftName !== (root.modelData.name ?? "")) {
					root.fieldEdited("name", draftName);
				}
			}

			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			Layout.fillHeight: true
			Layout.preferredWidth: root.width / 2

			HoverHandler {
				id: nameHover

			}

			CustomText {
				anchors.left: parent.left
				anchors.right: editButton.left
				anchors.rightMargin: Appearance.spacing.small
				anchors.verticalCenter: parent.verticalCenter
				elide: Text.ElideRight    // enable if CustomText supports it
				font.pointSize: Appearance.font.size.larger
				text: root.modelData.name
				visible: !nameCell.editing
			}

			IconButton {
				id: editButton

				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				font.pointSize: Appearance.font.size.large
				icon: "edit"
				visible: nameHover.hovered && !nameCell.editing

				onClicked: nameCell.beginEdit()
			}

			CustomRect {
				anchors.fill: parent
				color: DynamicColors.tPalette.m3surface
				radius: Appearance.rounding.small
				visible: nameCell.editing

				CustomTextField {
					id: nameEditor

					anchors.fill: parent
					text: nameCell.draftName

					Keys.onEscapePressed: {
						nameCell.cancelEdit();
					}
					onEditingFinished: {
						nameCell.commitEdit();
					}
					onTextEdited: {
						nameCell.draftName = nameEditor.text;
					}
				}
			}
		}

		VSeparator {
		}

		ColumnLayout {
			id: cLayout

			Layout.fillWidth: true

			RowLayout {
				Layout.fillWidth: true

				CustomText {
					Layout.fillWidth: true
					text: qsTr("Timeout")
				}

				CustomRect {
					Layout.preferredHeight: 33
					Layout.preferredWidth: Math.max(Math.min(timeField.contentWidth + Appearance.padding.normal * 3, 200), 50)
					color: DynamicColors.tPalette.m3surface
					radius: Appearance.rounding.small

					CustomTextField {
						id: timeField

						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: String(root.modelData.timeout ?? "")

						onEditingFinished: {
							root.fieldEdited("timeout", Number(text));
						}
					}
				}
			}

			Separator {
			}

			RowLayout {
				Layout.fillWidth: true

				CustomText {
					Layout.fillWidth: true
					text: qsTr("Idle Action")
				}

				CustomRect {
					Layout.preferredHeight: 33
					Layout.preferredWidth: Math.max(Math.min(idleField.contentWidth + Appearance.padding.normal * 3, 200), 50)
					color: DynamicColors.tPalette.m3surface
					radius: Appearance.rounding.small

					CustomTextField {
						id: idleField

						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: root.modelData.idleAction ?? ""

						onEditingFinished: {
							root.fieldEdited("idleAction", text);
						}
					}
				}
			}

			Separator {
			}

			Item {
				Layout.fillWidth: true
				implicitHeight: activeActionRow.visible ? activeActionRow.implicitHeight : addButtonRow.implicitHeight

				RowLayout {
					id: activeActionRow

					anchors.left: parent.left
					anchors.right: parent.right
					visible: root.modelData.activeAction !== undefined

					CustomText {
						Layout.fillWidth: true
						text: qsTr("Active Action")
					}

					CustomRect {
						Layout.preferredHeight: 33
						Layout.preferredWidth: Math.max(Math.min(actionField.contentWidth + Appearance.padding.normal * 3, 200), 50)
						color: DynamicColors.tPalette.m3surface
						radius: Appearance.rounding.small

						CustomTextField {
							id: actionField

							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: root.modelData.activeAction ?? ""

							onEditingFinished: {
								root.fieldEdited("activeAction", text);
							}
						}
					}
				}

				RowLayout {
					id: addButtonRow

					anchors.left: parent.left
					anchors.right: parent.right
					visible: root.modelData.activeAction === undefined

					IconButton {
						id: button

						Layout.alignment: Qt.AlignLeft
						font.pointSize: Appearance.font.size.large
						icon: "add"

						onClicked: console.log(button.width)
						// onClicked: root.addActiveActionRequested()
					}

					CustomText {
						Layout.alignment: Qt.AlignLeft
						text: qsTr("Add active action")
					}
				}
			}
		}
	}
}
