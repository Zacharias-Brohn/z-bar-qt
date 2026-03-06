import Quickshell.Io
import Quickshell

JsonObject {
	property Apps apps: Apps {
	}
	property Color color: Color {
	}
	property Idle idle: Idle {
	}
	property string logo: ""
	property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/Wallpapers"

	component Apps: JsonObject {
		property list<string> audio: ["pavucontrol"]
		property list<string> explorer: ["dolphin"]
		property list<string> playback: ["mpv"]
		property list<string> terminal: ["kitty"]
	}
	component Color: JsonObject {
		property string mode: "dark"
		property bool neovimColors: false
		property int scheduleDarkEnd: 0
		property int scheduleDarkStart: 0
		property bool schemeGeneration: true
		property bool wallust: false
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
