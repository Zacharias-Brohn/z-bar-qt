pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Helpers

Item {
	id: root

	required property var wrapper

	ColumnLayout {
		id: layout

		spacing: 8

		Repeater {
			model: Network.devices

			CustomRadioButton {
				id: network
				visible: modelData.name !== "lo"

				required property NetworkDevice modelData

				checked: Network.activeDevice?.name === modelData.name
				onClicked: 
				text: modelData.description
			}
		}
	}
}
