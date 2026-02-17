pragma Singleton

import Quickshell
import Quickshell.Io
import qs.Paths

Singleton {
    id: root

    property alias currentWallpaperPath: adapter.currentWallpaperPath
	property alias lockscreenBg: adapter.lockscreenBg

    FileView {
        id: fileView
        path: `${Paths.state}/wallpaper_path.json`

        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        JsonAdapter {
            id: adapter
            property string currentWallpaperPath: ""
			property string lockscreenBg: `${Paths.state}/lockscreen_bg.png`
        }
    }
}
