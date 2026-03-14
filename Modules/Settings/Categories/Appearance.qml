import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Modules.Settings.Controls
import qs.Config
import qs.Helpers

CustomFlickable {
	id: root

	contentHeight: clayout.implicitHeight

	TapHandler {
		acceptedButtons: Qt.LeftButton

		onTapped: function (eventPoint) {
			const menu = SettingsDropdowns.activeMenu;
			if (!menu)
				return;

			const p = eventPoint.scenePosition;

			if (SettingsDropdowns.hit(SettingsDropdowns.activeTrigger, p))
				return;

			if (SettingsDropdowns.hit(menu, p))
				return;

			SettingsDropdowns.closeActive();
		}
	}

	ColumnLayout {
		id: clayout

		anchors.left: parent.left
		anchors.right: parent.right

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: colorLayout.implicitHeight + Appearance.padding.normal * 2
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.normal - Appearance.padding.smaller

			ColumnLayout {
				id: colorLayout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.large
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: Appearance.spacing.normal

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

				SettingSpinner {
					name: "Schedule dark mode"
					object: Config.general.color
					settings: ["scheduleDarkStart", "scheduleDarkEnd"]
					z: 2
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
