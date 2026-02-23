import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Modules.Settings.Controls
import qs.Config
import qs.Helpers

CustomRect {
	id: root

	ColumnLayout {
		id: clayout
		
		anchors.left: parent.left
		anchors.right: parent.right

		CustomRect {
			
			Layout.preferredHeight: colorLayout.implicitHeight
			Layout.fillWidth: true

			color: DynamicColors.tPalette.m3surfaceContainer
			
			ColumnLayout {
				id: colorLayout

				anchors.left: parent.left
				anchors.right: parent.right
				anchors.margins: Appearance.padding.large

				Settings {
					name: "smth"
				}

				SettingSwitch {
					name: "wallust"
					setting: Config.general.color.wallust
				}
			}
		}
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		Layout.preferredWidth: 200
		Layout.preferredHeight: 42
		radius: 4

		CustomText {
			id: text

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.margins: Appearance.padding.smaller

			text: settingsItem.name
			font.pointSize: 32
			font.bold: true
			verticalAlignment: Text.AlignVCenter
		}
	}
}
