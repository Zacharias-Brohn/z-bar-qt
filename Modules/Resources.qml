pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import qs.Modules
import qs.Config
import qs.Effects

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: 34
    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3tertiaryFixed : "#ffffff"

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: 22
        color: Config.useDynamicColors ? DynamicColors.tPalette.m3surfaceContainer : "#40000000"
        radius: height / 2
        RowLayout {
            id: rowLayout

            spacing: 6
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\uf7a3"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.memoryUsedPercentage
                warningThreshold: 95
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue322"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.cpuUsage
                warningThreshold: 80
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 16
                text: "\ue30f"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.gpuUsage
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue30d"
                color: root.textColor
                Behavior on color {
                    CAnim {}
                }
            }

            Resource {
                percentage: ResourceUsage.gpuMemUsage
            }
        }
    }

    Item {
        id: popoutWindow
        z: 0
        property int rectHeight: contentRect.implicitHeight
        anchors.fill: parent
        visible: true

        // ShadowRect {
        //     anchors.fill: contentRect
        //     radius: 8
        // }

        ParallelAnimation {
            id: openAnim
            Anim {
                target: contentRect
                property: "implicitHeight"
                to: contentColumn.childrenRect.height + 20
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        ParallelAnimation {
            id: closeAnim
            Anim {
                target: contentRect
                property: "implicitHeight"
                to: 0
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        Rectangle {
            id: contentRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.bottom
            color: Config.useDynamicColors ? DynamicColors.tPalette.m3surface : Config.baseBgColor
            border.color: Config.useDynamicColors ? "transparent" : Config.baseBorderColor
            border.width: 1
            bottomLeftRadius: 8
            bottomRightRadius: 8
            clip: true

            Column {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ResourceDetail {
                    resourceName: qsTr( "Memory Usage" )
                    iconString: "\uf7a3"
                    percentage: ResourceUsage.memoryUsedPercentage
                    warningThreshold: 95
                    details: qsTr( "%1 of %2 MB used" )
                    .arg( Math.round( ResourceUsage.memoryUsed * 0.001 ))
                    .arg( Math.round( ResourceUsage.memoryTotal * 0.001 ))
                }

                ResourceDetail {
                    resourceName: qsTr( "CPU Usage" )
                    iconString: "\ue322"
                    percentage: ResourceUsage.cpuUsage
                    warningThreshold: 95
                    details: qsTr( "%1% used" )
                    .arg( Math.round( ResourceUsage.cpuUsage * 100 ))
                }

                ResourceDetail {
                    resourceName: qsTr( "GPU Usage" )
                    iconString: "\ue30f"
                    percentage: ResourceUsage.gpuUsage
                    warningThreshold: 95
                    details: qsTr( "%1% used" )
                    .arg( Math.round( ResourceUsage.gpuUsage * 100 ))
                }

                ResourceDetail {
                    resourceName: qsTr( "VRAM Usage" )
                    iconString: "\ue30d"
                    percentage: ResourceUsage.gpuMemUsage
                    warningThreshold: 95
                    details: qsTr( "%1% used" )
                    .arg( Math.round( ResourceUsage.gpuMemUsage * 100 ))
                }
            }
        }
        MouseArea {
            id: widgetMouseArea
            z: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: contentRect.bottom
            hoverEnabled: true
            onEntered: {
                openAnim.start();
            }
            onExited: {
                closeAnim.start();
            }
        }
    }
}
