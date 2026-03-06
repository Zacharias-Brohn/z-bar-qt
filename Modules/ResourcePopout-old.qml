pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config

Item {
	id: popoutWindow

	required property var wrapper

	implicitHeight: contentColumn.implicitHeight + 10
	implicitWidth: contentColumn.implicitWidth + 10 * 2

	// ShadowRect {
	//     anchors.fill: contentRect
	//     radius: 8
	// }

	ColumnLayout {
		id: contentColumn

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: 10

		ResourceDetail {
			details: qsTr("%1 of %2 MB used").arg(Math.round(ResourceUsage.memoryUsed * 0.001)).arg(Math.round(ResourceUsage.memoryTotal * 0.001))
			iconString: "\uf7a3"
			percentage: ResourceUsage.memoryUsedPercentage
			resourceName: qsTr("Memory Usage")
			warningThreshold: 95
		}

		ResourceDetail {
			details: qsTr("%1% used").arg(Math.round(ResourceUsage.cpuUsage * 100))
			iconString: "\ue322"
			percentage: ResourceUsage.cpuUsage
			resourceName: qsTr("CPU Usage")
			warningThreshold: 95
		}

		ResourceDetail {
			details: qsTr("%1% used").arg(Math.round(ResourceUsage.gpuUsage * 100))
			iconString: "\ue30f"
			percentage: ResourceUsage.gpuUsage
			resourceName: qsTr("GPU Usage")
			warningThreshold: 95
		}

		ResourceDetail {
			details: qsTr("%1% used").arg(Math.round(ResourceUsage.gpuMemUsage * 100))
			iconString: "\ue30d"
			percentage: ResourceUsage.gpuMemUsage
			resourceName: qsTr("VRAM Usage")
			warningThreshold: 95
		}
	}
}
