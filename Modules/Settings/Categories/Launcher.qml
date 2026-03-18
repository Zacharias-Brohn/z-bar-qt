import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Launcher"
		}

		SettingSpinBox {
			name: "Max apps shown"
			min: 1
			object: Config.launcher
			setting: "maxAppsShown"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Max wallpapers shown"
			min: 1
			object: Config.launcher
			setting: "maxWallpapers"
		}

		Separator {
		}

		SettingInput {
			name: "Action prefix"
			object: Config.launcher
			setting: "actionPrefix"
		}

		Separator {
		}

		SettingInput {
			name: "Special prefix"
			object: Config.launcher
			setting: "specialPrefix"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Fuzzy Search"
		}

		SettingSwitch {
			name: "Apps"
			object: Config.launcher.useFuzzy
			setting: "apps"
		}

		Separator {
		}

		SettingSwitch {
			name: "Actions"
			object: Config.launcher.useFuzzy
			setting: "actions"
		}

		Separator {
		}

		SettingSwitch {
			name: "Schemes"
			object: Config.launcher.useFuzzy
			setting: "schemes"
		}

		Separator {
		}

		SettingSwitch {
			name: "Variants"
			object: Config.launcher.useFuzzy
			setting: "variants"
		}

		Separator {
		}

		SettingSwitch {
			name: "Wallpapers"
			object: Config.launcher.useFuzzy
			setting: "wallpapers"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Sizes"
		}

		SettingSpinBox {
			name: "Item width"
			min: 1
			object: Config.launcher.sizes
			setting: "itemWidth"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Item height"
			min: 1
			object: Config.launcher.sizes
			setting: "itemHeight"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Wallpaper width"
			min: 1
			object: Config.launcher.sizes
			setting: "wallpaperWidth"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Wallpaper height"
			min: 1
			object: Config.launcher.sizes
			setting: "wallpaperHeight"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Actions"
		}

		SettingActionList {
			name: "Launcher actions"
			object: Config.launcher
			setting: "actions"
		}
	}
}
