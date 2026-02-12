pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules
import qs.Helpers as Helpers

Item {
	id: root

	required property var wrapper

	Component.onCompleted: console.log(Networking.backend.toString())

	ColumnLayout {
		id: layout

		spacing: 8

		Repeater {
			model: Helpers.Network.devices

			CustomRadioButton {
				id: network
				visible: modelData.name !== "lo"

				required property NetworkDevice modelData

				checked: Helpers.Network.activeDevice?.name === modelData.name
				text: modelData.description
			}
		}
	}
}
