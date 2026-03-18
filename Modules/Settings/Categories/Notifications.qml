import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Notifications"
		}

		SettingSwitch {
			name: "Expire notifications"
			object: Config.notifs
			setting: "expire"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Default expire timeout"
			min: 0
			object: Config.notifs
			setting: "defaultExpireTimeout"
			step: 100
		}

		Separator {
		}

		SettingSpinBox {
			name: "App notification cooldown"
			min: 0
			object: Config.notifs
			setting: "appNotifCooldown"
			step: 100
		}

		Separator {
		}

		SettingSpinBox {
			name: "Clear threshold"
			max: 1
			min: 0
			object: Config.notifs
			setting: "clearThreshold"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			name: "Expand threshold"
			min: 0
			object: Config.notifs
			setting: "expandThreshold"
		}

		Separator {
		}

		SettingSwitch {
			name: "Action on click"
			object: Config.notifs
			setting: "actionOnClick"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Group preview count"
			min: 1
			object: Config.notifs
			setting: "groupPreviewNum"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Sizes"
		}

		SettingSpinBox {
			name: "Width"
			min: 1
			object: Config.notifs.sizes
			setting: "width"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Image size"
			min: 1
			object: Config.notifs.sizes
			setting: "image"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Badge size"
			min: 1
			object: Config.notifs.sizes
			setting: "badge"
		}
	}
}
