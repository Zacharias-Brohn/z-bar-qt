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

		implicitHeight: 42
		implicitWidth: 200
		radius: 4

		RowLayout {
			id: layout

			anchors.left: parent.left
			anchors.margins: Appearance.padding.smaller
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter

			CustomText {
				id: text

				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.leftMargin: Appearance.spacing.normal
				text: settingsItem.name
				verticalAlignment: Text.AlignVCenter
			}
		}
	}
}
