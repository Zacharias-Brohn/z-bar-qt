import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Config
import qs.Helpers
import qs.Components

Item {
    id: root

	required property PersistentProperties visibilities

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
                // Hyprland.dispatch("global zshell-nc:toggle-nc");
				root.visibilities.sidebar = !root.visibilities.sidebar;
            }
        }
    }
}
