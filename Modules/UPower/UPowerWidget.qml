import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Helpers
import qs.Modules

Item {
	id: root

	implicitWidth: 100
	anchors.top: parent.top
	anchors.bottom: parent.bottom

	Component.onCompleted: UPower.findDevice()

	CustomText {
		text: UPower.batteryDevice.percentage + "%"
		anchors.centerIn: parent
	}
}
