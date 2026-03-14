import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Config
import qs.Helpers

CustomRect {
	id: root

	ColumnLayout {
		id: clayout

		anchors.fill: parent
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		Layout.preferredHeight: 60
		Layout.preferredWidth: 200

		CustomText {
			id: text

			anchors.fill: parent
			font.bold: true
			font.pointSize: Appearance.font.size.large * 2
			text: settingsItem.name
			verticalAlignment: Text.AlignVCenter
		}
	}
}
