pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {

    property alias appCount: adapter.appCount
    property alias baseBgColor: adapter.baseBgColor
    property alias accentColor: adapter.accentColor
    property alias wallpaperPath: adapter.wallpaperPath
    property alias maxWallpapers: adapter.maxWallpapers
    property alias wallust: adapter.wallust

    FileView {
        id: root
        property var configRoot: Quickshell.env("HOME")

        path: configRoot + "/.config/z-bar/config.json"

        watchChanges: true
        onFileChanged: reload()

        onAdapterChanged: writeAdapter()

        JsonAdapter {
            id: adapter
            property int appCount: 20
            property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/Wallpapers"
            property string baseBgColor: "#801a1a1a"
            property AccentColor accentColor: AccentColor {}
            property int maxWallpapers: 7
            property bool wallust: false
        }
    }
}
