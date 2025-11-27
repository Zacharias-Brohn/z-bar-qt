import QtQuick
import qs.Config
import qs.Modules

Item {
    implicitWidth: timeText.contentWidth
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Text {
        id: timeText

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        text: Time.time
        color: Config.useDynamicColors ? DynamicColors.palette.m3tertiary : "white"

        Behavior on color {
            CAnim {}
        }
    }
}
