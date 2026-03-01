import Quickshell.Io
import QtQuick

JsonObject {
	property real audioIncrement: 0.1
	property real brightnessIncrement: 0.1
	property bool ddcutilService: false
	property string defaultPlayer: "Spotify"
	property string gpuType: ""
	property real maxVolume: 1.0
	property list<var> playerAliases: [
		{
			"from": "com.github.th_ch.youtube_music",
			"to": "YT Music"
		}
	]
	property bool useFahrenheit: false
	property bool useTwelveHourClock: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().includes("a")
	property int visualizerBars: 30
	property string weatherLocation: ""
}
