import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config

Item {
    id: root
    required property string resourceName
    required property double percentage
    required property int warningThreshold
    required property string details
    required property string iconString
    property color barColor: Config.useDynamicColors ? DynamicColors.palette.m3primary : Config.accentColor.accents.primary
    property color warningBarColor: Config.useDynamicColors ? DynamicColors.palette.m3error : Config.accentColor.accents.warning
    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3onSurface : "#ffffff"

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

            Text {
                font.family: "Material Symbols Rounded"
                font.pixelSize: 32
                text: root.iconString
                color: root.textColor
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.resourceName
                font.pixelSize: 14
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

        Text {
            Layout.alignment: Qt.AlignLeft
            text: root.details
            font.pixelSize: 12
            color: "#cccccc"
        }
    }
}
