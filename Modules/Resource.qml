import qs.Modules
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import qs.Config

Item {
    id: root
    required property double percentage
    property int warningThreshold: 100
    property bool shown: true
    clip: true
    visible: width > 0 && height > 0
    implicitWidth: resourceRowLayout.x < 0 ? 0 : resourceRowLayout.implicitWidth
    implicitHeight: 22
    property bool warning: percentage * 100 >= warningThreshold

    Behavior on percentage {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    RowLayout {
        id: resourceRowLayout
        spacing: 2
        x: shown ? 0 : -resourceRowLayout.width
        anchors {
            verticalCenter: parent.verticalCenter
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 14
            implicitHeight: root.implicitHeight

            Rectangle {
                id: backgroundCircle
                anchors.centerIn: parent
                width: 14
                height: 14
                radius: height / 2
                color: "#40000000"
                border.color: "#404040"
                border.width: 1
            }

            Shape {
                anchors.fill: backgroundCircle

                smooth: true
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeWidth: 0
                    fillColor: root.warning ? Config.accentColor.accents.warning : Config.accentColor.accents.primary
                    startX: backgroundCircle.width / 2
                    startY: backgroundCircle.height / 2
                    PathLine {
                        x: backgroundCircle.width / 2
                        y: 0 + ( 1 / 2 )
                    }

                    PathAngleArc {
                        centerX: backgroundCircle.width / 2
                        centerY: backgroundCircle.height / 2
                        radiusX: backgroundCircle.width / 2 - ( 1 / 2 )
                        radiusY: backgroundCircle.height / 2 - ( 1 / 2 )
                        startAngle: -90
                        sweepAngle: 360 * root.percentage
                    }

                    PathLine {
                        x: backgroundCircle.width / 2
                        y: backgroundCircle.height / 2
                    }
                }

                ShapePath {
                    strokeWidth: 1
                    strokeColor: root.warning ? Config.accentColor.accents.warningAlt : Config.accentColor.accents.primaryAlt
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap

                    PathAngleArc {
                        centerX: backgroundCircle.width / 2
                        centerY: backgroundCircle.height / 2
                        radiusX: backgroundCircle.width / 2 - ( 1 / 2 )
                        radiusY: backgroundCircle.height / 2 - ( 1 / 2 )
                        startAngle: -90
                        sweepAngle: 360 * root.percentage
                    }
                }
            }
        }
    }
}
