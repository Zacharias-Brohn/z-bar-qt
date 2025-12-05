import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Helpers
import qs.Modules
import qs.Config

Loader {

	asynchronous: true
	active: Config.background.enabled

	sourceComponent: Variants {
		model: Quickshell.screens
		PanelWindow {
			id: root
			required property var modelData
			screen: modelData
			WlrLayershell.namespace: "ZShell-Wallpaper"
			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Bottom
			color: "transparent"

			anchors {
				top: true
				left: true
				right: true
				bottom: true
			}
			WallBackground {}
		}
	}
}
