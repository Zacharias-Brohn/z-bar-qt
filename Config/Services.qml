import Quickshell.Io
import QtQuick

JsonObject {
    property string weatherLocation: ""
    property bool useFahrenheit: false
    property bool useTwelveHourClock: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().includes("a")
    property string gpuType: ""
    property real audioIncrement: 0.1
    property real brightnessIncrement: 0.1
    property real maxVolume: 1.0
    property string defaultPlayer: "Spotify"
    property list<var> playerAliases: [
        {
            "from": "com.github.th_ch.youtube_music",
            "to": "YT Music"
        }
    ]
}
