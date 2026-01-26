pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
	id: root

	property list<NetworkDevice> devices: Networking.devices
	property NetworkDevice activeDevice: devices.find(d => d.connected)
}
