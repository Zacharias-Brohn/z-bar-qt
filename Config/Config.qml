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
    property alias transparency: adapter.transparency
    property alias baseFont: adapter.baseFont
    property alias animScale: adapter.animScale
    property alias lock: adapter.lock
	property alias idle: adapter.idle
	property alias overview: adapter.overview
	property alias services: adapter.services
	property alias notifs: adapter.notifs
	property alias sidebar: adapter.sidebar
	property alias utilities: adapter.utilities
	property alias general: adapter.general
	property alias dashboard: adapter.dashboard
	property alias appearance: adapter.appearance
	property alias autoHide: adapter.autoHide
	property alias macchiato: adapter.macchiato
	property alias osd: adapter.osd

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
            property Transparency transparency: Transparency {}
            property string baseFont: "Segoe UI Variable Text"
            property real animScale: 1.0
            property LockConf lock: LockConf {}
			property IdleTimeout idle: IdleTimeout {}
			property Overview overview: Overview {}
			property Services services: Services {}
			property NotifConfig notifs: NotifConfig {}
			property SidebarConfig sidebar: SidebarConfig {}
			property UtilConfig utilities: UtilConfig {}
			property General general: General {}
			property DashboardConfig dashboard: DashboardConfig {}
			property AppearanceConf appearance: AppearanceConf {}
			property bool autoHide: false
			property bool macchiato: false
			property Osd osd: Osd {}
        }
    }
}
