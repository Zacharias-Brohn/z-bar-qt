pragma Singleton

import Quickshell

Singleton {
	readonly property AppearanceConf.Anim anim: Config.appearance.anim
	readonly property AppearanceConf.FontStuff font: Config.appearance.font
	readonly property AppearanceConf.Padding padding: Config.appearance.padding
	// Literally just here to shorten accessing stuff :woe:
	// Also kinda so I can keep accessing it with `Appearance.xxx` instead of `Conf.appearance.xxx`
	readonly property AppearanceConf.Rounding rounding: Config.appearance.rounding
	readonly property AppearanceConf.Spacing spacing: Config.appearance.spacing
	readonly property AppearanceConf.Transparency transparency: Config.appearance.transparency
}
