pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Components

Scope {
	id: root

	property alias lock: lock
	property int seenOnce: 0

	WlSessionLock {
		id: lock

		signal requestLock
		signal unlock

		LockSurface {
			id: lockSurface

			lock: lock
			pam: pam
		}
	}

	Pam {
		id: pam

		lock: lock
	}

	IpcHandler {
		function lock() {
			return lock.locked = true;
		}

		target: "lock"
	}

	CustomShortcut {
		description: "Lock the current session"
		name: "lock"

		onPressed: {
			lock.locked = true;
		}
	}
}
