pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
	id: root

	readonly property list<UPowerDevice> devices: UPower.devices.values
	readonly property UPowerDevice displayDevice: UPower.displayDevice
	readonly property bool onBattery: UPower.onBattery
}
