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

    height: columnLayout.childrenRect.height
    anchors.left: parent.left
    anchors.right: parent.right

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
                color: "#ffffff"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.resourceName
                font.pixelSize: 14
                color: "#ffffff"
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
                color: root.percentage * 100 >= root.warningThreshold ? Config.accentColor.accents.warning : Config.accentColor.accents.primary

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
