import QtQuick
import qs.Config
import qs.Modules

Item {
    implicitWidth: timeText.contentWidth
    implicitHeight: timeText.contentHeight
    Text {
        id: timeText
        text: Time.time
        color: Config.useDynamicColors ? DynamicColors.palette.m3tertiary : "white"

        Behavior on color {
            CAnim {}
        }
    }
}
