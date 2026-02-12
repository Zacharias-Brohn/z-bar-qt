import Quickshell.Io

JsonObject {
	property Popouts popouts: Popouts {}

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
			id: "resources",
			enabled: true
		},
		{
			id: "updates",
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

	component Popouts: JsonObject {
		property bool tray: true
		property bool audio: true
		property bool activeWindow: true
		property bool resources: true
		property bool clock: true
		property bool network: true
		property bool upower: true
	}
}
