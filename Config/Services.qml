import Quickshell.Io
import QtQuick

JsonObject {
	property string weatherLocation: ""
	property real brightnessIncrement: 0.1
	property string defaultPlayer: "Spotify"
	property list<var> playerAliases: [
		{
			"from": "com.github.th_ch.youtube_music",
			"to": "YT Music"
		}
	]
}
