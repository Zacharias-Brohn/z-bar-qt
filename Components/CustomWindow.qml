import Quickshell
import Quickshell.Wayland

PanelWindow {
	required property string name

	WlrLayershell.namespace: `ZShell-${name}`
	color: "transparent"
}
