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

		Settings {
			name: "apps"
		}

		Item {
			
		}
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		implicitWidth: 200
		implicitHeight: 42
		radius: 4

		RowLayout {
			id: layout

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.margins: Appearance.padding.smaller

			CustomText {
				id: text

				text: settingsItem.name
				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: Appearance.spacing.normal
				verticalAlignment: Text.AlignVCenter
			}
		}
	}
}
