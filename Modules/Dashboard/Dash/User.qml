import qs.Components
import qs.Config
import qs.Paths
import qs.Helpers
import qs.Modules
import Quickshell
import QtQuick

Row {
    id: root

    required property PersistentProperties state

    padding: 20
    spacing: 12

    CustomClippingRect {
        implicitWidth: info.implicitHeight
        implicitHeight: info.implicitHeight

        radius: 8
        color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)

        MaterialIcon {
            anchors.centerIn: parent

            text: "person"
            fill: 1
            grade: 200
            font.pointSize: Math.floor(info.implicitHeight / 2) || 1
        }

        CachingImage {
            id: pfp

            anchors.fill: parent
            path: `${Paths.home}/.face`
        }
    }

    Column {
        id: info

        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Item {
            id: line

            implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin
            implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)

            ColoredIcon {
                id: icon

                anchors.left: parent.left
                anchors.leftMargin: (Config.dashboard.sizes.infoIconSize - implicitWidth) / 2

                source: SystemInfo.osLogo
                implicitSize: Math.floor(13 * 1.34)
                color: DynamicColors.palette.m3primary
            }

            CustomText {
                id: text

                anchors.verticalCenter: icon.verticalCenter
                anchors.left: icon.right
                anchors.leftMargin: icon.anchors.leftMargin
                text: `:  ${SystemInfo.osPrettyName || SystemInfo.osName}`
                font.pointSize: 13

                width: Config.dashboard.sizes.infoWidth
                elide: Text.ElideRight
            }
        }

        InfoLine {
            icon: "select_window_2"
            text: SystemInfo.wm
            colour: DynamicColors.palette.m3secondary
        }

        InfoLine {
            id: uptime

            icon: "timer"
            text: qsTr("up %1").arg(SystemInfo.uptime)
            colour: DynamicColors.palette.m3tertiary
        }
    }

    component InfoLine: Item {
        id: line

        required property string icon
        required property string text
        required property color colour

        implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin
        implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)

        MaterialIcon {
            id: icon

            anchors.left: parent.left
            anchors.leftMargin: (Config.dashboard.sizes.infoIconSize - implicitWidth) / 2

            fill: 1
            text: line.icon
            color: line.colour
            font.pointSize: 13
        }

        CustomText {
            id: text

            anchors.verticalCenter: icon.verticalCenter
            anchors.left: icon.right
            anchors.leftMargin: icon.anchors.leftMargin
            text: `:  ${line.text}`
            font.pointSize: 13

            width: Config.dashboard.sizes.infoWidth
            elide: Text.ElideRight
        }
    }
}
