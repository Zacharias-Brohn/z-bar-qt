//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QS_NO_RELOAD_POPUP=1
import Quickshell
import qs.Modules
import qs.Modules.Wallpaper
import qs.Modules.Lock
import qs.Drawers
import qs.Helpers
import qs.Modules.Polkit

ShellRoot {
	Bar {
	}

	Wallpaper {
	}

	AreaPicker {
	}

	Lock {
		id: lock

	}

	Shortcuts {
	}

	IdleMonitors {
		lock: lock
	}

	Polkit {
	}
}
