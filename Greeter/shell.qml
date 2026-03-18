pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Components

ShellRoot {
	id: root

	GreeterState {
		id: greeter

		username: "zach"
	}

	GreeterSurface {
		id: greeterSurface

		greeter: greeter
	}

	Connections {
		function onLastWindowClosed(): void {
			Qt.quit();
		}

		target: Quickshell
	}
}
