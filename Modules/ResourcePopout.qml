pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config

Item {
    id: popoutWindow
    implicitWidth: contentColumn.implicitWidth + 10 * 2
    implicitHeight: contentColumn.implicitHeight + 10
    required property var wrapper

    // ShadowRect {
    //     anchors.fill: contentRect
    //     radius: 8
    // }

    ColumnLayout {
        id: contentColumn
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
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
