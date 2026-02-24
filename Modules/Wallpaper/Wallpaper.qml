import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Config

Loader {
	active: Config.background.enabled
	asynchronous: true

	sourceComponent: Variants {
		model: Quickshell.screens

		PanelWindow {
			id: root

			required property var modelData

			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Bottom
			WlrLayershell.namespace: "ZShell-Wallpaper"
			color: "transparent"
			screen: modelData

			anchors {
				bottom: true
				left: true
				right: true
				top: true
			}

			WallBackground {
			}
		}
	}
}
