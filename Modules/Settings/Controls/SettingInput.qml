import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property string name
	required property var object
	required property string setting

	function formattedValue(): string {
		const value = root.object[root.setting];

		if (value === null || value === undefined)
			return "";

		return String(value);
	}

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

		CustomRect {
			id: rect

			Layout.preferredHeight: 33
			Layout.preferredWidth: Math.max(Math.min(textField.contentWidth + Appearance.padding.normal * 2, 550), 50)
			color: DynamicColors.tPalette.m3surfaceContainerHigh
			radius: Appearance.rounding.full

			CustomTextField {
				id: textField

				anchors.centerIn: parent
				horizontalAlignment: Text.AlignHCenter
				implicitWidth: Math.min(contentWidth, 550)
				text: root.formattedValue()

				onEditingFinished: {
					root.object[root.setting] = textField.text;
					Config.save();
				}
			}
		}
	}
}
