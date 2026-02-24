pragma Singleton

import Quickshell
import Quickshell.Io
import ZShell.Models
import qs.Config
import qs.Modules
import qs.Helpers
import qs.Paths

Searcher {
	id: root

	property string actualCurrent: WallpaperPath.currentWallpaperPath
	readonly property string current: showPreview ? previewPath : actualCurrent
	property string previewPath
	property bool showPreview: false

	function preview(path: string): void {
		previewPath = path;
		if (Config.general.color.schemeGeneration)
			Quickshell.execDetached(["sh", "-c", `zshell-cli scheme generate --image-path ${previewPath} --thumbnail-path ${Paths.cache}/imagecache/thumbnail.jpg --output ${Paths.state}/scheme.json --scheme ${Config.colors.schemeType} --mode ${Config.general.color.mode}`]);
		showPreview = true;
	}

	function setWallpaper(path: string): void {
		actualCurrent = path;
		WallpaperPath.currentWallpaperPath = path;
		if (Config.general.color.wallust)
			Wallust.generateColors(WallpaperPath.currentWallpaperPath);
		Quickshell.execDetached(["sh", "-c", `zshell-cli wallpaper lockscreen --input-image=${root.actualCurrent} --output-path=${Paths.state}/lockscreen_bg.png --blur-amount=${Config.lock.blurAmount}`]);
	}

	function stopPreview(): void {
		showPreview = false;
		if (Config.general.color.schemeGeneration)
			Quickshell.execDetached(["sh", "-c", `zshell-cli scheme generate --image-path ${root.actualCurrent} --thumbnail-path ${Paths.cache}/imagecache/thumbnail.jpg --output ${Paths.state}/scheme.json --scheme ${Config.colors.schemeType} --mode ${Config.general.color.mode}`]);
	}

	extraOpts: useFuzzy ? ({}) : ({
			forward: false
		})
	key: "relativePath"
	list: wallpapers.entries
	useFuzzy: true

	IpcHandler {
		function set(path: string): void {
			root.setWallpaper(path);
		}

		target: "wallpaper"
	}

	FileSystemModel {
		id: wallpapers

		filter: FileSystemModel.Images
		path: Config.general.wallpaperPath
		recursive: true
	}
}
