import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

Item {
    id: root

    implicitWidth: 20
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    MaterialIcon {
        id: notificationCenterIcon

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        property color iconColor: Config.useDynamicColors ? DynamicColors.palette.m3tertiaryFixed : "white"

        text: HasNotifications.hasNotifications ? "\uf4fe" : "\ue7f4"
        font.family: "Material Symbols Rounded"
        font.pixelSize: 20
        color: iconColor

        Behavior on color {
            CAnim {}
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                ncProcess.running = true
            }
        }
    }
}
