import QtQuick
import qs.Config
import qs.Modules
import qs.Components

CustomText {
    text: Time.time
    color: Config.useDynamicColors ? DynamicColors.palette.m3tertiary : "white"

    Behavior on color {
        CAnim {}
    }
}
