pragma Singleton

import Quickshell.Io
import Quickshell

Singleton {
    id: root

    property alias notifPath: storage.notifPath

    JsonAdapter {
        id: storage

        property string notifPath: Quickshell.statePath("notifications.json")
    }
}
