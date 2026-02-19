import Quickshell.Io
import Quickshell

JsonObject {
	property string logo: ""
	property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/Wallpapers"
	property Color color: Color {}
	property Apps apps: Apps {}
    property Idle idle: Idle {}

	component Color: JsonObject {
		property bool wallust: false
		property bool schemeGeneration: true
		property string mode: "dark"
		property int scheduleDarkStart: 0
		property int scheduleDarkEnd: 0
	}

    component Apps: JsonObject {
        property list<string> terminal: ["kitty"]
        property list<string> audio: ["pavucontrol"]
        property list<string> playback: ["mpv"]
        property list<string> explorer: ["dolphin"]
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
