import Quickshell.Io
import Quickshell

JsonObject {
	property string logo: ""
	property string wallpaperPath: Quickshell.env("HOME") + "/Pictures/Wallpapers"
	property bool wallust: false
    property Idle idle: Idle {}

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
