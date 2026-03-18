import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property string name
	required property var object
	required property string setting
	property string addLabel: qsTr("Add entry")

	Layout.fillWidth: true
	Layout.preferredHeight: layout.implicitHeight

	ColumnLayout {
		id: layout

		anchors.left: parent.left
		anchors.right: parent.right
		spacing: Appearance.spacing.small

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		StringListEditor {
			Layout.fillWidth: true
			addLabel: root.addLabel
			values: [...(root.object[root.setting] ?? [])]

			onListEdited: function (values) {
				root.object[root.setting] = values;
				Config.save();
			}
		}
	}
}
