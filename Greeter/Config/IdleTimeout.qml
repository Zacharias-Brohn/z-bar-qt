import Quickshell.Io

JsonObject {
	property list<var> timeouts: [
		{
			timeout: 180,
			idleAction: "lock"
		},
		{
			timeout: 300,
			idleAction: "dpms off",
			activeAction: "dpms on"
		}
	]
}
