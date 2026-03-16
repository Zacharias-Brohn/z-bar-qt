import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Bar"
		}

		SettingSwitch {
			name: "Auto hide"
			object: Config.barConfig
			setting: "autoHide"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Height"
			min: 1
			object: Config.barConfig
			setting: "height"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Rounding"
			min: 0
			object: Config.barConfig
			setting: "rounding"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Border"
			min: 0
			object: Config.barConfig
			setting: "border"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Popouts"
		}

		SettingSwitch {
			name: "Tray"
			object: Config.barConfig.popouts
			setting: "tray"
		}

		Separator {
		}

		SettingSwitch {
			name: "Audio"
			object: Config.barConfig.popouts
			setting: "audio"
		}

		Separator {
		}

		SettingSwitch {
			name: "Active window"
			object: Config.barConfig.popouts
			setting: "activeWindow"
		}

		Separator {
		}

		SettingSwitch {
			name: "Resources"
			object: Config.barConfig.popouts
			setting: "resources"
		}

		Separator {
		}

		SettingSwitch {
			name: "Clock"
			object: Config.barConfig.popouts
			setting: "clock"
		}

		Separator {
		}

		SettingSwitch {
			name: "Network"
			object: Config.barConfig.popouts
			setting: "network"
		}

		Separator {
		}

		SettingSwitch {
			name: "Power"
			object: Config.barConfig.popouts
			setting: "upower"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Entries"
		}

		SettingBarEntryList {
			name: "Bar entries"
			object: Config.barConfig
			setting: "entries"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Dock"
		}

		SettingSwitch {
			name: "Enable dock"
			object: Config.dock
			setting: "enable"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Dock height"
			min: 1
			object: Config.dock
			setting: "height"
		}

		Separator {
		}

		SettingSwitch {
			name: "Hover to reveal"
			object: Config.dock
			setting: "hoverToReveal"
		}

		Separator {
		}

		SettingSwitch {
			name: "Pin on startup"
			object: Config.dock
			setting: "pinnedOnStartup"
		}

		Separator {
		}

		SettingStringList {
			name: "Pinned apps"
			addLabel: qsTr("Add pinned app")
			object: Config.dock
			setting: "pinnedApps"
		}

		Separator {
		}

		SettingStringList {
			name: "Ignored app regexes"
			addLabel: qsTr("Add ignored regex")
			object: Config.dock
			setting: "ignoredAppRegexes"
		}
	}
}
