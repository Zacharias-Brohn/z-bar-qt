//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QS_NO_RELOAD_POPUP=1
import Quickshell
import qs.Modules
import qs.Modules.Lock as Lock
import qs.Helpers
import qs.Modules.Polkit

Scope {
    Bar {}
    Wallpaper {}
    Launcher {}
    AreaPicker {}
	Lock.Lock {
		id: lock
	}

	Lock.IdleInhibitor {
		lock: lock
	}

	// NotificationCenter {
	//
	// }

	Polkit {}
}
