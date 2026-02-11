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

    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent: WallpaperPath.currentWallpaperPath

    function setWallpaper(path: string): void {
        actualCurrent = path;
        WallpaperPath.currentWallpaperPath = path;
		Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/LockScreenBg.py"), `--input_image=${root.actualCurrent}`, `--output_path=${Paths.state}/lockscreen_bg.png`]);
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;
    }

    function stopPreview(): void {
        showPreview = false;
        Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/SchemeColorGen.py"), `--path=${root.actualCurrent}`, `--thumbnail=${Paths.cache}/imagecache/thumbnail.jpg`, `--output=${Paths.state}/scheme.json`, `--scheme=${Config.colors.schemeType}`]);
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: true
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Config.wallpaperPath
        filter: FileSystemModel.Images
    }
}
