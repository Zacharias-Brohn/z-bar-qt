//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
import Quickshell
import qs.Modules
import qs.Modules.Lock
import qs.Modules.WSOverview
import qs.Helpers

Scope {
    Bar {}
    Wallpaper {}
    Launcher {}
    AreaPicker {}
	Lock {
		id: lock
	}

	IdleInhibitor {
		lock: lock
	}

	NotificationCenter {

	}

	Overview {}
}
