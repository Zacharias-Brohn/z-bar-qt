import QtQuick
import qs.Components
import qs.Config

Item {
    id: root
    required property string text
    property bool shown: false
    property real horizontalPadding: 10
    property real verticalPadding: 5
    implicitWidth: tooltipTextObject.implicitWidth + 2 * root.horizontalPadding
    implicitHeight: tooltipTextObject.implicitHeight + 2 * root.verticalPadding

    property bool isVisible: backgroundRectangle.implicitHeight > 0

    Rectangle {
        id: backgroundRectangle
        anchors {
            bottom: root.bottom
            horizontalCenter: root.horizontalCenter
        }
        color: DynamicColors.tPalette.m3inverseSurface ?? "#3C4043"
        radius: 8
        opacity: shown ? 1 : 0
        implicitWidth: shown ? (tooltipTextObject.implicitWidth + 2 * root.horizontalPadding) : 0
        implicitHeight: shown ? (tooltipTextObject.implicitHeight + 2 * root.verticalPadding) : 0
        clip: true

        Behavior on implicitWidth {
            Anim {}
        }
        Behavior on implicitHeight {
            Anim {}
        }
        Behavior on opacity {
            Anim {}
        }

        CustomText {
            id: tooltipTextObject
            anchors.centerIn: parent
            text: root.text
            color: DynamicColors.palette.m3inverseOnSurface ?? "#FFFFFF"
            wrapMode: Text.Wrap
        }
    }   
}
