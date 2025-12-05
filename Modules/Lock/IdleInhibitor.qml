pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import qs.Config
import qs.Helpers

Scope {
	id: root

	required property Lock lock
	readonly property bool enabled: !Players.list.some( p => p.isPlaying )

	function handleIdleAction( action: var ): void {
		if ( !action )
			return;

		if ( action === "lock" )
			lock.lock.locked = true;
		else if ( action === "unlock" )
			lock.lock.locked = false;
		else if ( typeof action === "string" )
			Hypr.dispatch( action );
		else
			Quickshell.execDetached( action );
	}

	Variants {
		model: Config.idle.timeouts

		IdleMonitor {
			required property var modelData

			enabled: root.enabled && modelData.timeout > 0 ? true : false
			timeout: modelData.timeout
			onIsIdleChanged: root.handleIdleAction( isIdle ? modelData.idleAction : modelData.activeAction )
		}
	}
}
