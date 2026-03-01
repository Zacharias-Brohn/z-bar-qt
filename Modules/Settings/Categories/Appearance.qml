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
			Layout.fillWidth: true
			Layout.preferredHeight: colorLayout.implicitHeight
			color: DynamicColors.tPalette.m3surfaceContainer

			ColumnLayout {
				id: colorLayout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.large
				anchors.right: parent.right

				Settings {
					name: "smth"
				}

				SettingSwitch {
					name: "wallust"
					object: Config.general.color
					setting: "wallust"
				}

				CustomSplitButtonRow {
					enabled: true
					label: qsTr("Scheme mode")

					menuItems: [
						MenuItem {
							property string val: "light"

							icon: "light_mode"
							text: qsTr("Light")
						},
						MenuItem {
							property string val: "dark"

							icon: "dark_mode"
							text: qsTr("Dark")
						}
					]

					Component.onCompleted: {
						if (Config.general.color.mode === "light")
							active = menuItems[0];
						else
							active = menuItems[1];
					}
					onSelected: item => {
						Config.general.color.mode = item.val;
						Config.save();
					}
				}
			}
		}
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		Layout.preferredHeight: 42
		Layout.preferredWidth: 200
		radius: 4

		CustomText {
			id: text

			anchors.left: parent.left
			anchors.margins: Appearance.padding.smaller
			anchors.right: parent.right
			font.bold: true
			font.pointSize: 32
			text: settingsItem.name
			verticalAlignment: Text.AlignVCenter
		}
	}
}
