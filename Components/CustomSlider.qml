import QtQuick
import QtQuick.Templates
import qs.Config
import qs.Modules

Slider {
    id: root

    background: Item {
        CustomRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            implicitWidth: root.handle.x - root.implicitHeight / 6

            color: DynamicColors.palette.m3primary
            radius: 1000
            topRightRadius: root.implicitHeight / 15
            bottomRightRadius: root.implicitHeight / 15
        }

        CustomRect {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: root.implicitHeight / 3
            anchors.bottomMargin: root.implicitHeight / 3

            implicitWidth: parent.width - root.handle.x - root.handle.implicitWidth - root.implicitHeight / 6

            color: DynamicColors.tPalette.m3surfaceContainer
            radius: 1000
            topLeftRadius: root.implicitHeight / 15
            bottomLeftRadius: root.implicitHeight / 15
        }
    }

    handle: CustomRect {
        x: root.visualPosition * root.availableWidth - implicitWidth / 2

        implicitWidth: root.implicitHeight / 4.5
        implicitHeight: root.implicitHeight

        color: DynamicColors.palette.m3primary
        radius: 1000

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
