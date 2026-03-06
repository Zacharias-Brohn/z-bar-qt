import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

RowLayout {
	id: root

	required property string name
	required property var object
	required property string setting

	Layout.fillWidth: true
	Layout.preferredHeight: 42

	CustomText {
		id: text

		Layout.alignment: Qt.AlignLeft
		Layout.fillWidth: true
		font.pointSize: 16
		text: root.name
	}

	CustomSwitch {
		id: cswitch

		Layout.alignment: Qt.AlignRight
		checked: root.object[root.setting]

		onToggled: {
			root.object[root.setting] = checked;
			Config.save();
		}
	}
}
