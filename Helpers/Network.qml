pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
	id: root

	property NetworkDevice activeDevice: devices.find(d => d.connected)
	property list<NetworkDevice> devices: Networking.devices.values
}
