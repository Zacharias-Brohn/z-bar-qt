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

		CustomText {
			Layout.alignment: Qt.AlignLeft
			Layout.preferredWidth: root.width / 2
			font.pointSize: Appearance.font.size.larger
			text: root.modelData.name
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

					Item {
						Layout.fillWidth: true
					}

					CustomButton {
						text: qsTr("Add active action")

						onClicked: root.addActiveActionRequested()
					}
				}
			}
		}
	}
}
