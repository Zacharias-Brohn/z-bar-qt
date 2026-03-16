import qs.Modules.Settings.Categories.Lockscreen
import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	id: root

	SettingsSection {
		SettingsHeader {
			name: "Lockscreen"
		}

		SettingSwitch {
			name: "Recolor logo"
			object: Config.lock
			setting: "recolorLogo"
		}

		Separator {
		}

		SettingSwitch {
			name: "Enable fingerprint"
			object: Config.lock
			setting: "enableFprint"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Max fingerprint tries"
			min: 1
			object: Config.lock
			setting: "maxFprintTries"
			step: 1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Blur amount"
			min: 0
			object: Config.lock
			setting: "blurAmount"
			step: 1
		}

		Separator {
		}

		SettingSpinBox {
			name: "Height multiplier"
			max: 2
			min: 0.1
			object: Config.lock.sizes
			setting: "heightMult"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			name: "Aspect ratio"
			max: 4
			min: 0.5
			object: Config.lock.sizes
			setting: "ratio"
			step: 0.05
		}

		Separator {
		}

		SettingSpinBox {
			name: "Center width"
			min: 100
			object: Config.lock.sizes
			setting: "centerWidth"
			step: 10
		}
	}

	SettingsSection {
		Idle {
		}
	}
}
