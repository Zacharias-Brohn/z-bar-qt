import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property string name
	required property var object
	required property string setting
	property real max: Infinity
	property real min: -Infinity
	property real step: 1

	Layout.fillWidth: true
	Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		CustomText {
			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomSpinBox {
			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
			max: root.max
			min: root.min
			step: root.step
			value: Number(root.object[root.setting] ?? 0)

			onValueModified: function (value) {
				root.object[root.setting] = value;
				Config.save();
			}
		}
	}
}
