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

    required property var visibilities
    required property Item popouts

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + 18 * 2

    radius: 8
    color: DynamicColors.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 7

			Toggle {
				visible: QSNetwork.Networking.devices.values.length > 0
				icon: Network.wifiEnabled ? "wifi" : "wifi_off"
				checked: Network.wifiEnabled
				onClicked: Network.toggleWifi()
			}

            Toggle {
				id: toggle
                icon: NotifServer.dnd ? "notifications_off" : "notifications"
                checked: !NotifServer.dnd
                onClicked: NotifServer.dnd = !NotifServer.dnd
            }

			Toggle {
				icon: Audio.sourceMuted ? "mic_off" : "mic"
				checked: !Audio.sourceMuted
				onClicked: {
					const audio = Audio.source?.audio;
					if ( audio )
						audio.muted = !audio.muted;
				}
			}

			Toggle {
				icon: Audio.muted ? "volume_off" : "volume_up"
				checked: !Audio.muted
				onClicked: {
					const audio = Audio.sink?.audio;
					if ( audio )
						audio.muted = !audio.muted;
				}
			}

			Toggle {
				visible: Bluetooth.defaultAdapter?.enabled ?? false
				icon: Bluetooth.defaultAdapter?.enabled ? "bluetooth" : "bluetooth_disabled"
				checked: Bluetooth.defaultAdapter?.enabled ?? false
				onClicked: {
					const adapter = Bluetooth.defaultAdapter
					if ( adapter )
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
        radius: stateLayer.pressed ? 6 / 2 : internalChecked ? 6 : 8
        inactiveColour: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
        toggle: true
        radiusAnim.duration: MaterialEasing.expressiveEffectsTime
        radiusAnim.easing.bezierCurve: MaterialEasing.expressiveEffects

        Behavior on Layout.preferredWidth {
            Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }
    }
}
