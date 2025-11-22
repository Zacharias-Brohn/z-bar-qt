import QtQuick
import QtQuick.Templates
import qs.Config
import qs.Modules

RadioButton {
    id: root

    font.pointSize: 12

    implicitWidth: implicitIndicatorWidth + implicitContentWidth + contentItem.anchors.leftMargin
    implicitHeight: Math.max(implicitIndicatorHeight, implicitContentHeight)

    indicator: Rectangle {
        id: outerCircle

        implicitWidth: 20
        implicitHeight: 20
        radius: 1000
        color: "transparent"
        border.color: root.checked ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
        border.width: 2
        anchors.verticalCenter: parent.verticalCenter

        StateLayer {
            anchors.margins: -7
            color: root.checked ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3primary
            z: -1

            function onClicked(): void {
                root.click();
            }
        }

        CustomRect {
            anchors.centerIn: parent
            implicitWidth: 8
            implicitHeight: 8

            radius: 1000
            color: Qt.alpha(DynamicColors.palette.m3primary, root.checked ? 1 : 0)
        }

        Behavior on border.color {
            CAnim {}
        }
    }

    contentItem: CustomText {
        text: root.text
        font.pointSize: root.font.pointSize
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: outerCircle.right
        anchors.leftMargin: 10
    }
}
