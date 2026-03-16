import qs.Modules.Settings.Controls
import qs.Config

SettingsPage {
	SettingsSection {
		SettingsHeader {
			name: "Utilities"
		}

		SettingSwitch {
			name: "Enable utilities"
			object: Config.utilities
			setting: "enabled"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Max toasts"
			min: 1
			object: Config.utilities
			setting: "maxToasts"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Panel width"
			min: 1
			object: Config.utilities.sizes
			setting: "width"
		}

		Separator {
		}

		SettingSpinBox {
			name: "Toast width"
			min: 1
			object: Config.utilities.sizes
			setting: "toastWidth"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "Toasts"
		}

		SettingSwitch {
			name: "Config loaded"
			object: Config.utilities.toasts
			setting: "configLoaded"
		}

		Separator {
		}

		SettingSwitch {
			name: "Charging changed"
			object: Config.utilities.toasts
			setting: "chargingChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Game mode changed"
			object: Config.utilities.toasts
			setting: "gameModeChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Do not disturb changed"
			object: Config.utilities.toasts
			setting: "dndChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Audio output changed"
			object: Config.utilities.toasts
			setting: "audioOutputChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Audio input changed"
			object: Config.utilities.toasts
			setting: "audioInputChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Caps lock changed"
			object: Config.utilities.toasts
			setting: "capsLockChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Num lock changed"
			object: Config.utilities.toasts
			setting: "numLockChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Keyboard layout changed"
			object: Config.utilities.toasts
			setting: "kbLayoutChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "VPN changed"
			object: Config.utilities.toasts
			setting: "vpnChanged"
		}

		Separator {
		}

		SettingSwitch {
			name: "Now playing"
			object: Config.utilities.toasts
			setting: "nowPlaying"
		}
	}

	SettingsSection {
		SettingsHeader {
			name: "VPN"
		}

		SettingSwitch {
			name: "Enable VPN integration"
			object: Config.utilities.vpn
			setting: "enabled"
		}

		Separator {
		}

		SettingStringList {
			name: "Provider"
			addLabel: qsTr("Add VPN provider")
			object: Config.utilities.vpn
			setting: "provider"
		}
	}
}
