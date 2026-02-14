import QtQuick
import qs.Helpers
import qs.Components
import qs.Config

Item {
    id: root

    anchors.centerIn: parent

    implicitWidth: icon.implicitWidth + info.implicitWidth + info.anchors.leftMargin

    Component.onCompleted: Weather.reload()

    MaterialIcon {
        id: icon

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        animate: true
        text: Weather.icon
        color: DynamicColors.palette.m3secondary
        font.pointSize: 54
    }

    Column {
        id: info

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
		anchors.leftMargin: Appearance.spacing.large

        spacing: 8

        CustomText {
            anchors.horizontalCenter: parent.horizontalCenter

            animate: true
            text: Weather.temp
            color: DynamicColors.palette.m3primary
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: 500
        }

        CustomText {
            anchors.horizontalCenter: parent.horizontalCenter

            animate: true
            text: Weather.description

            elide: Text.ElideRight
            width: Math.min(implicitWidth, root.parent.width - icon.implicitWidth - info.anchors.leftMargin - 24 * 2)
        }
    }
}
