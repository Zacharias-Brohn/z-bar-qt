import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Config
import qs.Helpers

RowLayout {
	id: root

	required property var object
	required property string setting
	required property string name
	
	Layout.preferredHeight: 42
	Layout.fillWidth: true
	
	CustomText {
		id: text
		
		text: root.name
		font.pointSize: 16
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignLeft
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
