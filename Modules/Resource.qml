import qs.Modules
import QtQuick
import QtQuick.Layouts
import Quickshell

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

            // Background circle
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

            // Pie progress indicator
            Canvas {
                id: progressCanvas
                anchors.fill: backgroundCircle

                Connections {
                    target: root
                    function onPercentageChanged() {
                        progressCanvas.requestPaint()
                    }
                    function onWarningChanged() {
                        progressCanvas.requestPaint()
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    
                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = width / 2;
                    var startAngle = -Math.PI / 2; // Start at top
                    var endAngle = startAngle + (2 * Math.PI * percentage);

                    ctx.fillStyle = warning ? "#ff6b6b" : "#4080ff";
                    ctx.beginPath();
                    ctx.moveTo(centerX, centerY);
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                    ctx.lineTo(centerX, centerY);
                    ctx.fill();
                }
            }

            // // Percentage text
            // Item {
            //     anchors.centerIn: backgroundCircle
            //     implicitWidth: fullPercentageTextMetrics.width
            //     implicitHeight: percentageText.implicitHeight
            //
            //     TextMetrics {
            //         id: fullPercentageTextMetrics
            //         text: "100"
            //         font.pixelSize: 12
            //     }
            //
            //     Text {
            //         id: percentageText
            //         anchors.centerIn: parent
            //         color: "#ffffff"
            //         font.pixelSize: 12
            //         font.bold: true
            //         text: `${Math.round(percentage * 100).toString()}`
            //     }
            // }
        }
    }
}
