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
		showPreview = true;
	}

	function setWallpaper(path: string): void {
		actualCurrent = path;
		WallpaperPath.currentWallpaperPath = path;
		Quickshell.execDetached(["sh", "-c", `python3 ${Quickshell.shellPath("scripts/LockScreenBg.py")} --input_image=${root.actualCurrent} --output_path=${Paths.state}/lockscreen_bg.png`]);
	}

	function stopPreview(): void {
		showPreview = false;
		Quickshell.execDetached(["sh", "-c", `python3 ${Quickshell.shellPath("scripts/SchemeColorGen.py")} --path=${root.actualCurrent} --thumbnail=${Paths.cache}/imagecache/thumbnail.jpg --output=${Paths.state}/scheme.json --scheme=${Config.colors.schemeType}`]);
	}

	extraOpts: useFuzzy ? ({}) : ({
			forward: false
		})
	key: "relativePath"
	list: wallpapers.entries
	useFuzzy: true

	FileSystemModel {
		id: wallpapers

		filter: FileSystemModel.Images
		path: Config.general.wallpaperPath
		recursive: true
	}
}
