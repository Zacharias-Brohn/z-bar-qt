pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property string lockscreenBg: `${Quickshell.shellDir}/images/greeter_bg.png`
}
