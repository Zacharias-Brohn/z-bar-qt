import Quickshell.Io
import Quickshell

JsonObject {
	property string logo: ""
	property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/Wallpapers"
	property bool wallust: false
	property Apps apps: Apps {}
    property Idle idle: Idle {}

    component Apps: JsonObject {
        property list<string> terminal: ["foot"]
        property list<string> audio: ["pavucontrol"]
        property list<string> playback: ["mpv"]
        property list<string> explorer: ["thunar"]
    }

	component Idle: JsonObject {
		property list<var> timeouts: [
			{
				timeout: 180,
				idleAction: "lock"
			},
			{
				timeout: 300,
				idleAction: "dpms off",
				activeAction: "dpms on"
			}
		]
	}
}
