import Quickshell.Bluetooth
import Quickshell.Networking as QSNetwork
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons

CustomRect {
	id: root

	required property Item popouts
	required property var visibilities

	Layout.fillWidth: true
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + 18 * 2
	radius: 8

	ColumnLayout {
		id: layout

		anchors.fill: parent
		anchors.margins: 18
		spacing: 10

		RowLayout {
			Layout.alignment: Qt.AlignHCenter
			spacing: 7

			Toggle {
				checked: Network.wifiEnabled
				icon: Network.wifiEnabled ? "wifi" : "wifi_off"
				visible: QSNetwork.Networking.devices.values.length > 0

				onClicked: Network.toggleWifi()
			}

			Toggle {
				id: toggle

				checked: !NotifServer.dnd
				icon: NotifServer.dnd ? "notifications_off" : "notifications"

				onClicked: NotifServer.dnd = !NotifServer.dnd
			}

			Toggle {
				checked: !Audio.sourceMuted
				icon: Audio.sourceMuted ? "mic_off" : "mic"

				onClicked: {
					const audio = Audio.source?.audio;
					if (audio)
						audio.muted = !audio.muted;
				}
			}

			Toggle {
				checked: !Audio.muted
				icon: Audio.muted ? "volume_off" : "volume_up"

				onClicked: {
					const audio = Audio.sink?.audio;
					if (audio)
						audio.muted = !audio.muted;
				}
			}

			Toggle {
				checked: Bluetooth.defaultAdapter?.enabled ?? false
				icon: Bluetooth.defaultAdapter?.enabled ? "bluetooth" : "bluetooth_disabled"
				visible: Bluetooth.defaultAdapter ?? false

				onClicked: {
					const adapter = Bluetooth.defaultAdapter;
					if (adapter)
						adapter.enabled = !adapter.enabled;
				}
			}
		}
	}

	CustomShortcut {
		name: "toggle-dnd"

		onPressed: {
			toggle.clicked();
		}
	}

	component Toggle: IconButton {
		Layout.fillWidth: true
		Layout.preferredWidth: implicitWidth + (stateLayer.pressed ? 18 : internalChecked ? 7 : 0)
		inactiveColour: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
		radius: stateLayer.pressed ? 6 / 2 : internalChecked ? 6 : 8
		radiusAnim.duration: MaterialEasing.expressiveEffectsTime
		radiusAnim.easing.bezierCurve: MaterialEasing.expressiveEffects
		toggle: true

		Behavior on Layout.preferredWidth {
			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}
	}
}
