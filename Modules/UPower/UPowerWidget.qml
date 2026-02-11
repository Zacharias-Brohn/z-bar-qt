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

	function findDevice() {
		for ( let i = 0; i < UPower.devices.count; i++ ) {
			if ( UPower.devices[i].isLaptopBattery ) {
				return UPower.devices[i];
			}
		}
	}

	CustomText {
		text: findDevice().percentage
		anchors.centerIn: parent
	}
}
