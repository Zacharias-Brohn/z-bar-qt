pragma Singleton

import Quickshell
import Quickshell.Io
import qs.Modules

Singleton {

    property alias appCount: adapter.appCount
    property alias baseBgColor: adapter.baseBgColor
    property alias baseBorderColor: adapter.baseBorderColor
    property alias accentColor: adapter.accentColor
    property alias wallpaperPath: adapter.wallpaperPath
    property alias maxWallpapers: adapter.maxWallpapers
    property alias wallust: adapter.wallust
    property alias workspaceWidget: adapter.workspaceWidget
    property alias colors: adapter.colors
    property alias gpuType: adapter.gpuType
    property alias background: adapter.background
    property alias useDynamicColors: adapter.useDynamicColors
    property alias barConfig: adapter.barConfig

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
            property string baseBorderColor: "#444444"
            property AccentColor accentColor: AccentColor {}
            property int maxWallpapers: 7
            property bool wallust: false
            property WorkspaceWidget workspaceWidget: WorkspaceWidget {}
            property Colors colors: Colors {}
            property string gpuType: ""
            property BackgroundConfig background: BackgroundConfig {}
            property bool useDynamicColors: false
            property BarConfig barConfig: BarConfig {}
        }
    }
}
