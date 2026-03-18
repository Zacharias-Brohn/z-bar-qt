import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Dashboard"
		}

		SettingSwitch {
			name: "Enable dashboard"
			object: Config.dashboard
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Media update interval"
			min: 0
			object: Config.dashboard
			setting: "mediaUpdateInterval"
			step: 50
		}

		Separator {
		}

		SettingSpinBox {
			name: "Resource update interval"
			min: 0
			object: Config.dashboard
			setting: "resourceUpdateInterval"
			step: 50
		}

		Separator {
		}

		SettingSpinBox {
			name: "Drag threshold"
			min: 0
			object: Config.dashboard
			setting: "dragThreshold"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Performance"
		}

		SettingSwitch {
			name: "Show battery"
			object: Config.dashboard.performance
			setting: "showBattery"
		}

		Separator {
		}

		SettingSwitch {
			name: "Show GPU"
			object: Config.dashboard.performance
			setting: "showGpu"
		}

		Separator {
		}

		SettingSwitch {
			name: "Show CPU"
			object: Config.dashboard.performance
			setting: "showCpu"
		}

		Separator {
		}

		SettingSwitch {
			name: "Show memory"
			object: Config.dashboard.performance
			setting: "showMemory"
		}

		Separator {
		}

		SettingSwitch {
			name: "Show storage"
			object: Config.dashboard.performance
			setting: "showStorage"
		}

		Separator {
		}

		SettingSwitch {
			name: "Show network"
			object: Config.dashboard.performance
			setting: "showNetwork"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Layout Sizes"
		}

		SettingReadOnly {
			name: "Tab indicator height"
			value: String(Config.dashboard.sizes.tabIndicatorHeight)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Tab indicator spacing"
			value: String(Config.dashboard.sizes.tabIndicatorSpacing)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Info width"
			value: String(Config.dashboard.sizes.infoWidth)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Info icon size"
			value: String(Config.dashboard.sizes.infoIconSize)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Date time width"
			value: String(Config.dashboard.sizes.dateTimeWidth)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Media width"
			value: String(Config.dashboard.sizes.mediaWidth)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Media progress sweep"
			value: String(Config.dashboard.sizes.mediaProgressSweep)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Media progress thickness"
			value: String(Config.dashboard.sizes.mediaProgressThickness)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Resource progress thickness"
			value: String(Config.dashboard.sizes.resourceProgessThickness)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Weather width"
			value: String(Config.dashboard.sizes.weatherWidth)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Media cover art size"
			value: String(Config.dashboard.sizes.mediaCoverArtSize)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Media visualiser size"
			value: String(Config.dashboard.sizes.mediaVisualiserSize)
		}

		Separator {
		}

		SettingReadOnly {
			name: "Resource size"
			value: String(Config.dashboard.sizes.resourceSize)
		}
	}
}
