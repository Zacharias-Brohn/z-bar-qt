//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QS_NO_RELOAD_POPUP=1
import Quickshell
import qs.Modules
import qs.Modules.Lock as Lock
import qs.Helpers
import qs.Modules.Polkit

ShellRoot {
    Bar {}
    Wallpaper {}
    AreaPicker {}
	Lock.Lock {
		id: lock
	}

	Shortcuts {}
	Lock.IdleInhibitor {
		lock: lock
	}

	Polkit {}
}
