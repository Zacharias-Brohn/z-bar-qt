import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Modules.Settings.Controls
import qs.Modules.Settings.Categories.Appearance
import qs.Config
import qs.Helpers

CustomFlickable {
	id: root

	contentHeight: clayout.implicitHeight

	ColumnLayout {
		id: clayout

		anchors.left: parent.left
		anchors.right: parent.right

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: colorLayout.implicitHeight + Appearance.padding.normal * 2
			color: DynamicColors.tPalette.m3surfaceContainer

			ColumnLayout {
				id: colorLayout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.large
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter

				Settings {
					name: "Color"
				}

				SettingSwitch {
					name: "Automatic color scheme"
					object: Config.general.color
					setting: "schemeGeneration"
				}

				Separator {
				}

				SettingSwitch {
					name: "Smart color scheme"
					object: Config.general.color
					setting: "smart"
				}

				Separator {
				}

				SettingInput {
					name: "Schedule dark mode start"
					object: Config.general.color
					setting: "scheduleDarkStart"
				}

				Separator {
				}

				SettingInput {
					name: "Schedule dark mode end"
					object: Config.general.color
					setting: "scheduleDarkEnd"
				}

				Separator {
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

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: idleLayout.implicitHeight + Appearance.padding.normal * 2
			color: DynamicColors.tPalette.m3surfaceContainer

			Idle {
				id: idleLayout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.large
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
			}
		}
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		Layout.preferredHeight: 60
		Layout.preferredWidth: 200
		radius: 4

		CustomText {
			id: text

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			font.bold: true
			font.pointSize: Appearance.font.size.large * 2
			text: settingsItem.name
			verticalAlignment: Text.AlignVCenter
		}
	}
}
