pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.Config

Singleton {
    id: root

    property var args
	readonly property string mode: Config.general.color.mode
	readonly property string threshold: mode === "dark" ? "--threshold=9" : "--dynamic-threshold"

    function generateColors(wallpaperPath) {
        root.args = wallpaperPath;
        wallustProc.running = true;
    }

    Process {
        id: wallustProc
        command: ["wallust", "run", root.args, `--palette=${root.mode}`, "--ignore-sequence=cursor", `${root.threshold}` ]
        running: false
    }
}
