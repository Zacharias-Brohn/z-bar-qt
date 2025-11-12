pragma Singleton
import Quickshell.Io
import Quickshell

Singleton {

    function getInitialTitle(callback) {
        initialTitleProc.running = true
        initialTitleProc.stdout.streamFinished.connect( function() {
            let cleaned = initialTitleProc.stdout.text.trim().replace(/\"/g, "")
            callback(cleaned === "null" ? "" : cleaned)
        })
    }

    Process {
        id: initialTitleProc
        command: ["./scripts/initialTitle.sh"]
        running: false
        stdout: StdioCollector {
        }
    }
}
