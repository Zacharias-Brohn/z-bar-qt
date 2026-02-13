pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
    id: root

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: 110

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        CustomText {
            Layout.bottomMargin: -(font.pointSize * 0.4)
            Layout.alignment: Qt.AlignHCenter
            text: Time.hourStr
            color: DynamicColors.palette.m3secondary
            font.pointSize: 18
            font.family: "Rubik"
            font.weight: 600
        }

        CustomText {
            Layout.alignment: Qt.AlignHCenter
            text: "•••"
            color: DynamicColors.palette.m3primary
            font.pointSize: 18 * 0.9
            font.family: "Rubik"
        }

        CustomText {
            Layout.topMargin: -(font.pointSize * 0.4)
            Layout.alignment: Qt.AlignHCenter
            text: Time.minuteStr
            color: DynamicColors.palette.m3secondary
            font.pointSize: 18
            font.family: "Rubik"
            font.weight: 600
        }
    }
}
