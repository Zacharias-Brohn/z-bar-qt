pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias hasNotifications: adapter.hasNotifications

    JsonObject {
        id: adapter
        property bool hasNotifications: false
    }
}
