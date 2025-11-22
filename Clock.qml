import QtQuick
import qs.Config
import qs.Modules

Text {
    text: Time.time
    color: Config.useDynamicColors ? DynamicColors.palette.m3tertiary : "white"

    Behavior on color {
        CAnim {}
    }
}
