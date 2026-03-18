import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "On Screen Display"
		}

		SettingSwitch {
			name: "Enable OSD"
			object: Config.osd
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Hide delay"
			min: 0
			object: Config.osd
			setting: "hideDelay"
			step: 100
		}

		Separator {
		}

		SettingSwitch {
			name: "Enable brightness OSD"
			object: Config.osd
			setting: "enableBrightness"
		}

		Separator {
		}

		SettingSwitch {
			name: "Enable microphone OSD"
			object: Config.osd
			setting: "enableMicrophone"
		}

		Separator {
		}

		SettingSwitch {
			name: "Brightness on all monitors"
			object: Config.osd
			setting: "allMonBrightness"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Sizes"
		}

		SettingSpinBox {
			name: "Slider width"
			min: 1
			object: Config.osd.sizes
			setting: "sliderWidth"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Slider height"
			min: 1
			object: Config.osd.sizes
			setting: "sliderHeight"
		}
	}
}
