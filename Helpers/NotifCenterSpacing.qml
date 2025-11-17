pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias centerX: notifCenterSpacing.centerX

    JsonAdapter {
        id: notifCenterSpacing

        property int centerX
    }
}
