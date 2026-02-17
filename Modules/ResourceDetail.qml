import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components

Item {
    id: root
    required property string resourceName
    required property double percentage
    required property int warningThreshold
    required property string details
    required property string iconString
    property color barColor: DynamicColors.palette.m3primary
    property color warningBarColor: DynamicColors.palette.m3error
    property color textColor: DynamicColors.palette.m3onSurface

    Layout.preferredWidth: 158
    Layout.preferredHeight: columnLayout.implicitHeight

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 4

        Row {
            spacing: 6
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            MaterialIcon {
                font.family: "Material Symbols Rounded"
                font.pointSize: 28
                text: root.iconString
                color: root.textColor
            }

            CustomText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.resourceName
                font.pointSize: 12
                color: root.textColor
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: height / 2
            color: "#40000000"

            Rectangle {
                width: parent.width * Math.min(root.percentage, 1)
                height: parent.height
                radius: height / 2
                color: root.percentage * 100 >= root.warningThreshold ? root.warningBarColor : root.barColor

                Behavior on width {
                    Anim {
                        duration: MaterialEasing.expressiveEffectsTime
                        easing.bezierCurve: MaterialEasing.expressiveEffects
                    }
                }
            }
        }

        CustomText {
            Layout.alignment: Qt.AlignLeft
            text: root.details
            font.pointSize: 10
            color: "#cccccc"
        }
    }
}
