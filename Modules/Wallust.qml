pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var args

    function generateColors(wallpaperPath) {
        root.args = wallpaperPath;
        wallustProc.running = true;
    }

    Process {
        id: wallustProc
        command: ["wallust", "run", root.args, "--palette=dark", "--ignore-sequence=cursor", "--threshold=9" ]
        running: false
    }
}
