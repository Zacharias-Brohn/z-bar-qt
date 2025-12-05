pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import qs.Config

Scope {
	id: root

	property alias lock: lock
	property int seenOnce: 0

	Timer {
		interval: 500
		running: true
		repeat: false
		onTriggered: {
			if ( Config.lock.fixLockScreen ) {
				Quickshell.execDetached(["hyprctl", "keyword", "misc:session_lock_xray", "true"]);
				console.log("Fixed lock screen X-ray issue.");
			}
		}
	}

	WlSessionLock {
		id: lock

		signal unlock
		signal requestLock

		LockSurface {
			id: lockSurface
			lock: lock
			pam: pam
			scope: root
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
			lock.locked = true;
		}
	}
}


