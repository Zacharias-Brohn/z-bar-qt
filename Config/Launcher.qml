import Quickshell.Io

JsonObject {
	property int maxAppsShown: 10
	property int maxWallpapers: 7
	property string actionPrefix: ">"
    property string specialPrefix: "@"
    property Sizes sizes: Sizes {}
	property UseFuzzy useFuzzy: UseFuzzy {}

    component UseFuzzy: JsonObject {
        property bool apps: false
        property bool actions: false
        property bool schemes: false
        property bool variants: false
        property bool wallpapers: false
    }

    component Sizes: JsonObject {
        property int itemWidth: 600
        property int itemHeight: 50
        property int wallpaperWidth: 280
        property int wallpaperHeight: 200
    }

	property list<var> actions: [
		{
			name: "Calculator",
			icon: "calculate",
			description: "Do simple math equations (powered by Qalc)",
			command: ["autocomplete", "calc"],
			enabled: true,
			dangerous: false
		},
        {
            name: "Wallpaper",
            icon: "image",
            description: "Change the current wallpaper",
            command: ["autocomplete", "wallpaper"],
            enabled: true,
            dangerous: false
        },
        {
            name: "Shutdown",
            icon: "power_settings_new",
            description: "Shutdown the system",
            command: ["systemctl", "poweroff"],
            enabled: true,
            dangerous: true
        },
        {
            name: "Reboot",
            icon: "cached",
            description: "Reboot the system",
            command: ["systemctl", "reboot"],
            enabled: true,
            dangerous: true
        },
        {
            name: "Logout",
            icon: "exit_to_app",
            description: "Log out of the current session",
            command: ["loginctl", "terminate-user", ""],
            enabled: true,
            dangerous: true
        },
        {
            name: "Lock",
            icon: "lock",
            description: "Lock the current session",
            command: ["loginctl", "lock-session"],
            enabled: true,
            dangerous: false
        },
        {
            name: "Sleep",
            icon: "bedtime",
            description: "Suspend then hibernate",
            command: ["systemctl", "suspend-then-hibernate"],
            enabled: true,
            dangerous: false
        },
	]
}
