import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	id: root

	SettingsSection {
		SettingsHeader {
			name: "Scale"
		}

		SettingSpinBox {
			name: "Rounding scale"
			object: Config.appearance.rounding
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Spacing scale"
			object: Config.appearance.spacing
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Padding scale"
			object: Config.appearance.padding
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Font size scale"
			object: Config.appearance.font.size
			setting: "scale"
			step: 0.1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Animation duration scale"
			object: Config.appearance.anim.durations
			setting: "scale"
			step: 0.1
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Fonts"
		}

		SettingInput {
			name: "Sans family"
			object: Config.appearance.font.family
			setting: "sans"
		}

		Separator {
		}

		SettingInput {
			name: "Monospace family"
			object: Config.appearance.font.family
			setting: "mono"
		}

		Separator {
		}

		SettingInput {
			name: "Material family"
			object: Config.appearance.font.family
			setting: "material"
		}

		Separator {
		}

		SettingInput {
			name: "Clock family"
			object: Config.appearance.font.family
			setting: "clock"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Animation"
		}

		SettingSpinBox {
			name: "Media GIF speed adjustment"
			object: Config.appearance.anim
			setting: "mediaGifSpeedAdjustment"
			step: 10
		}

		Separator {
		}

		SettingSpinBox {
			name: "Session GIF speed"
			max: 5
			min: 0
			object: Config.appearance.anim
			setting: "sessionGifSpeed"
			step: 0.1
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Transparency"
		}

		SettingSwitch {
			name: "Enable transparency"
			object: Config.appearance.transparency
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Base opacity"
			max: 1
			min: 0
			object: Config.appearance.transparency
			setting: "base"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			name: "Layer opacity"
			max: 1
			min: 0
			object: Config.appearance.transparency
			setting: "layers"
			step: 0.05
		}
	}
}
