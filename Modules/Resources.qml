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

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: 22
        color: "#40000000"
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
                color: "#ffffff"
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
                color: "#ffffff"
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
                color: "#ffffff"
            }

            Resource {
                percentage: ResourceUsage.gpuUsage
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue30d"
                color: "#ffffff"
            }

            Resource {
                percentage: ResourceUsage.gpuMemUsage
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if (popoutLoader.sourceComponent === null) {
                popoutLoader.sourceComponent = resourcePopout;
            }
        }
    }

    Loader {
        id: popoutLoader
        sourceComponent: null
    }

    component ResourcePopout: PanelWindow {
        id: popoutWindow
        property alias containsMouse: popoutWindow.mouseAreaContainsMouse
        property int rectHeight: contentRect.implicitHeight
        property bool mouseAreaContainsMouse: mouseArea.containsMouse
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors {
            left: true
            top: true
            right: true
            bottom: true
        }

        color: "transparent"

        mask: Region { item: contentRect }

        ShadowRect {
            anchors.fill: contentRect
            radius: 8
        }

        ParallelAnimation {
            id: openAnim
            Anim {
                target: contentRect
                property: "y"
                to: 0 - 1
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
            onFinished: {
                if ( !mouseArea.containsMouse )
                    closeAnim.start();
            }
        }

        ParallelAnimation {
            id: closeAnim
            Anim {
                target: contentRect
                property: "y"
                to: - contentRect.implicitHeight
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
            onStopped: {
                popoutLoader.sourceComponent = null
            }
        }

        Rectangle {
            id: contentRect
            x: mapFromItem(root, 0, 0).x
            y: - implicitHeight
            implicitHeight: contentColumn.childrenRect.height + 20
            implicitWidth: root.implicitWidth
            color: Config.baseBgColor
            border.color: Config.baseBorderColor
            border.width: 1
            bottomLeftRadius: 8
            bottomRightRadius: 8


            Component.onCompleted: {
                openAnim.start();
            }

            Column {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ResourceDetail {
                    resourceName: qsTr("Memory Usage")
                    iconString: "\uf7a3"
                    percentage: ResourceUsage.memoryUsedPercentage
                    warningThreshold: 95
                    details: qsTr("%1 of %2 MB used")
                        .arg(Math.round(ResourceUsage.memoryUsed * 0.001))
                        .arg(Math.round(ResourceUsage.memoryTotal * 0.001))
                }

                ResourceDetail {
                    resourceName: qsTr("CPU Usage")
                    iconString: "\ue322"
                    percentage: ResourceUsage.cpuUsage
                    warningThreshold: 95
                    details: qsTr("%1% used")
                        .arg(Math.round(ResourceUsage.cpuUsage * 100))
                }

                ResourceDetail {
                    resourceName: qsTr("GPU Usage")
                    iconString: "\ue30f"
                    percentage: ResourceUsage.gpuUsage
                    warningThreshold: 95
                    details: qsTr("%1% used")
                        .arg(Math.round(ResourceUsage.gpuUsage * 100))
                }

                ResourceDetail {
                    resourceName: qsTr("VRAM Usage")
                    iconString: "\ue30d"
                    percentage: ResourceUsage.gpuMemUsage
                    warningThreshold: 95
                    details: qsTr("%1% used")
                        .arg(Math.round(ResourceUsage.gpuMemUsage * 100))
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    closeAnim.start();
                }
            }
        }
    }

    Component {
        id: resourcePopout

        ResourcePopout { }
    }
}
