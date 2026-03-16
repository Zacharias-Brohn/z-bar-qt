import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Sidebar"
		}

		SettingSwitch {
			name: "Enable sidebar"
			object: Config.sidebar
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Width"
			min: 1
			object: Config.sidebar.sizes
			setting: "width"
		}
	}
}
