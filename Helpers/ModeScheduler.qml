pragma Singleton

import Quickshell
import QtQuick
import qs.Modules
import qs.Helpers
import qs.Config
import qs.Paths

Singleton {
	id: root

	readonly property int darkEnd: Config.general.color.scheduleDarkEnd
	readonly property int darkStart: Config.general.color.scheduleDarkStart
	readonly property bool enabled: Config.general.color.scheduleDark

	function applyDarkMode() {
		if (Config.general.color.schemeGeneration) {
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--image-path", `${WallpaperPath.currentWallpaperPath}`, "--thumbnail-path", `${Paths.cache}/imagecache/thumbnail.jpg`, "--output", `${Paths.state}/scheme.json`, "--scheme", `${Config.colors.schemeType}`, "--mode", "dark"]);
		} else {
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--preset", `${DynamicColors.scheme}:${DynamicColors.flavour}`, "--output", `${Paths.state}/scheme.json`, "--mode", "dark"]);
		}

		Config.general.color.mode = "dark";

		Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", "'prefer-dark'"]);

		Quickshell.execDetached(["sh", "-c", `sed -i 's/color_scheme_path=\\(.*\\)Light.colors/color_scheme_path=\\1Dark.colors/' ${Paths.home}/.config/qt6ct/qt6ct.conf`]);

		Quickshell.execDetached(["sed", "-i", "'s/\\(vim.cmd.colorscheme \\).*/\\1\"tokyodark\"/'", "~/.config/nvim/lua/config/load-colorscheme.lua"]);
	}

	function applyLightMode() {
		if (Config.general.color.schemeGeneration) {
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--image-path", `${WallpaperPath.currentWallpaperPath}`, "--thumbnail-path", `${Paths.cache}/imagecache/thumbnail.jpg`, "--output", `${Paths.state}/scheme.json`, "--scheme", `${Config.colors.schemeType}`, "--mode", "light"]);
		} else {
			Quickshell.execDetached(["zshell-cli", "scheme", "generate", "--preset", `${DynamicColors.scheme}:${DynamicColors.flavour}`, "--output", `${Paths.state}/scheme.json`, "--mode", "light"]);
		}

		Config.general.color.mode = "light";

		Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", "'prefer-light'"]);

		Quickshell.execDetached(["sh", "-c", `sed -i 's/color_scheme_path=\\(.*\\)Dark.colors/color_scheme_path=\\1Light.colors/' ${Paths.home}/.config/qt6ct/qt6ct.conf`]);

		if (Config.general.color.neovimColors)
			Quickshell.execDetached(["sed", "-i", "'s/\\(vim.cmd.colorscheme \\).*/\\1\"onelight\"/'", "~/.config/nvim/lua/config/load-colorscheme.lua"]);
	}

	function checkStartup() {
		if (darkStart === darkEnd)
			return;
		var now = new Date();
		if (now.getHours() >= darkStart || now.getHours() < darkEnd) {
			applyDarkMode();
		} else {
			applyLightMode();
		}
	}

	Timer {
		id: darkModeTimer

		interval: 5000
		repeat: true
		running: true

		onTriggered: {
			if (!root.enabled)
				return;
			var now = new Date();
			if (now.getHours() >= root.darkStart || now.getHours() < root.darkEnd) {
				if (DynamicColors.light)
					root.applyDarkMode();
			} else {
				if (!DynamicColors.light)
					root.applyLightMode();
			}
		}
	}
}
