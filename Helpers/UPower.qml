pragma Singleton

import Quickshell
import Quickshell.Services.UPower


Singleton {
	id: root

	readonly property list<UPowerDevice> devices: UPower.devices.values
	readonly property bool onBattery: UPower.onBattery
	readonly property UPowerDevice displayDevice: UPower.displayDevice

	property UPowerDevice batteryDevice

	function findDevice(): void {
		for ( let i = 0; i < root.devices.length; i++ ) {
			if ( root.devices[i].type === "Battery" ) {
				root.batteryDevice = root.devices[i];
			}
		}
	}
}
