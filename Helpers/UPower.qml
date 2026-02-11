pragma Singleton

import Quickshell
import Quickshell.Services.UPower


Singleton {
	id: root

	readonly property list<UPowerDevice> devices: UPower.devices.values
	readonly property bool onBattery: UPower.onBattery
	readonly property UPowerDevice displayDevice: UPower.displayDevice

	property UPowerDevice batteryDevice: findDevice()

	function findDevice(): UPowerDevice {
		for ( let i = 0; i < root.devices.length; i++ ) {
			console.log(root.devices[i])
			if ( root.devices[i].isLaptopBattery ) {
				return root.devices[i];
			}
		}
	}
}
