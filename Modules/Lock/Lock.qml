pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Scope {
	id: root
	property alias lock: lock

	WlSessionLock {
		id: lock

		signal unlock

		LockSurface {
			lock: lock
			pam: pam
		}
	}

	Pam {
		id: pam

		lock: lock
	}

	GlobalShortcut {
		name: "lock"
		description: "Lock the current session"
		appid: "zshell-lock"
		onPressed: {
			lock.locked = true
		}
	}
}
