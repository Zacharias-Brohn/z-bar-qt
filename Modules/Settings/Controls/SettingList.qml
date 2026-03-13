import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property list<var> modelData
	required property string name

	Layout.fillWidth: true
	Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		CustomText {
			id: text

			Layout.alignment: Qt.AlignLeft
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		VSeparator {
		}

		ColumnLayout {
			id: cLayout

			RowLayout {
				id: timeLayout

				Layout.fillWidth: true

				CustomText {
					id: timeText

					Layout.fillWidth: true
					text: root.modelData.name
				}

				CustomRect {
					id: timeRect

					Layout.preferredHeight: 33
					Layout.preferredWidth: Math.max(Math.min(timeField.contentWidth + Appearance.padding.normal * 3, 200), 50)
					color: DynamicColors.tPalette.m3surface
					radius: Appearance.rounding.small

					CustomTextField {
						id: timeField

						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: root.modelData.timeout

						onEditingFinished: {
							root.modelData.timeout = timeField.text;
							Config.save();
						}
					}
				}
			}

			Separator {
			}

			RowLayout {
				id: idleLayout

				Layout.fillWidth: true

				CustomText {
					id: idleText

					Layout.fillWidth: true
					text: root.modelData.name
				}

				CustomRect {
					id: idleRect

					Layout.preferredHeight: 33
					Layout.preferredWidth: Math.max(Math.min(idleField.contentWidth + Appearance.padding.normal * 3, 200), 50)
					color: DynamicColors.tPalette.m3surface
					radius: Appearance.rounding.small

					CustomTextField {
						id: idleField

						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: root.modelData.idleAction

						onEditingFinished: {
							root.modelData.idleAction = idleField.text;
							Config.save();
						}
					}
				}
			}

			Separator {
			}

			Loader {
				id: loader

				Layout.fillWidth: true
				active: root.modelData.activeAction ?? false

				RowLayout {
					id: actionLayout

					CustomText {
						id: actionText

						Layout.fillWidth: true
						text: root.modelData.name
					}

					CustomRect {
						id: actionRect

						Layout.preferredHeight: 33
						Layout.preferredWidth: Math.max(Math.min(actionField.contentWidth + Appearance.padding.normal * 3, 200), 50)
						color: DynamicColors.tPalette.m3surface
						radius: Appearance.rounding.small

						CustomTextField {
							id: actionField

							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: root.modelData.activeAction

							onEditingFinished: {
								root.modelData.activeAction = actionField.text;
								Config.save();
							}
						}
					}
				}
			}
		}
	}
}
