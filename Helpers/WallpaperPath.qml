pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias currentWallpaperPath: adapter.currentWallpaperPath

    FileView {
        id: fileView
        path: Quickshell.env("HOME") + "/.local/state/z-bar/wallpaper_path.json"

        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        JsonAdapter {
            id: adapter
            property string currentWallpaperPath: ""
        }
    }
}
