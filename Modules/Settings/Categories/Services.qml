import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Services"
		}

		SettingInput {
			name: "Weather location"
			object: Config.services
			setting: "weatherLocation"
		}

		Separator {
		}

		SettingSwitch {
			name: "Use Fahrenheit"
			object: Config.services
			setting: "useFahrenheit"
		}

		Separator {
		}

		SettingSwitch {
			name: "Use twelve hour clock"
			object: Config.services
			setting: "useTwelveHourClock"
		}

		Separator {
		}

		SettingSwitch {
			name: "Enable ddcutil service"
			object: Config.services
			setting: "ddcutilService"
		}

		Separator {
		}

		SettingInput {
			name: "GPU type"
			object: Config.services
			setting: "gpuType"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Media"
		}

		SettingSpinBox {
			name: "Audio increment"
			max: 1
			min: 0
			object: Config.services
			setting: "audioIncrement"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			name: "Brightness increment"
			max: 1
			min: 0
			object: Config.services
			setting: "brightnessIncrement"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			name: "Max volume"
			max: 5
			min: 0
			object: Config.services
			setting: "maxVolume"
			step: 0.05
		}

		Separator {
		}

		SettingInput {
			name: "Default player"
			object: Config.services
			setting: "defaultPlayer"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Visualizer bars"
			min: 1
			object: Config.services
			setting: "visualizerBars"
			step: 1
		}

		Separator {
		}

		SettingAliasList {
			name: "Player aliases"
			object: Config.services
			setting: "playerAliases"
		}
	}
}
