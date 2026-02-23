import QtQuick
import QtQuick.Templates
import qs.Config

Slider {
    id: root

    background: Item {
        CustomRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            implicitWidth: root.handle.x - root.implicitHeight / 2

            color: DynamicColors.palette.m3primary
            radius: 1000
            topRightRadius: root.implicitHeight / 6
            bottomRightRadius: root.implicitHeight / 6
        }

        CustomRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            implicitWidth: parent.width - root.handle.x - root.handle.implicitWidth - root.implicitHeight / 2

            color: DynamicColors.tPalette.m3surfaceContainer
            radius: 1000
            topLeftRadius: root.implicitHeight / 6
            bottomLeftRadius: root.implicitHeight / 6
        }
    }

    handle: CustomRect {
        x: root.visualPosition * root.availableWidth - implicitWidth / 2

        implicitWidth: 5
        implicitHeight: 15
        anchors.verticalCenter: parent.verticalCenter

        color: DynamicColors.palette.m3primary
        radius: 1000

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
