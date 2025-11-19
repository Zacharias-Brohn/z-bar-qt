pragma Singleton

import Quickshell
import Quickshell.Io
import qs.Config
import qs.Modules
import qs.Helpers
import ZShell.Models

Searcher {
    id: root

    readonly property string currentNamePath: WallpaperPath.currentWallpaperPath

    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent: WallpaperPath.currentWallpaperPath

    function setWallpaper(path: string): void {
        actualCurrent = path;
        WallpaperPath.currentWallpaperPath = path;
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;
    }

    function stopPreview(): void {
        showPreview = false;
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: true
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.actualCurrent = this.text;
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Config.wallpaperPath
        filter: FileSystemModel.Images
    }
}
