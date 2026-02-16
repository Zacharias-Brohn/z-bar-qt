pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import qs.Components
import qs.Config

Scope {
	id: root

	property alias lock: lock
	property int seenOnce: 0

	WlSessionLock {
		id: lock

		signal unlock
		signal requestLock

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

	CustomShortcut {
		name: "lock"
		description: "Lock the current session"
		onPressed: {
			lock.locked = true;
		}
	}
}
