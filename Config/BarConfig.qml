import Quickshell.Io

JsonObject {
	property bool autoHide: false
	property list<var> entries: [
		{
			id: "workspaces",
			enabled: true
		},
		{
			id: "audio",
			enabled: true
		},
		{
			id: "media",
			enabled: true
		},
		{
			id: "resources",
			enabled: true
		},
		{
			id: "updates",
			enabled: true
		},
		{
			id: "dash",
			enabled: true
		},
		{
			id: "spacer",
			enabled: true
		},
		{
			id: "activeWindow",
			enabled: true
		},
		{
			id: "spacer",
			enabled: true
		},
		{
			id: "tray",
			enabled: true
		},
		{
			id: "upower",
			enabled: false
		},
		{
			id: "network",
			enabled: false
		},
		{
			id: "clock",
			enabled: true
		},
		{
			id: "notifBell",
			enabled: true
		},
	]
	property Popouts popouts: Popouts {
	}
	property int rounding: 8

	component Popouts: JsonObject {
		property bool activeWindow: true
		property bool audio: true
		property bool clock: true
		property bool network: true
		property bool resources: true
		property bool tray: true
		property bool upower: true
	}
}
