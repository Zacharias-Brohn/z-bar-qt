pragma Singleton

import ZShell
import ZShell.Internal
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.Components

Singleton {
	id: root

	property string activeName
	readonly property HyprlandToplevel activeToplevel: Hyprland.activeToplevel
	readonly property int activeWsId: focusedWorkspace?.id ?? 1
	property string applicationDir: "/usr/share/applications/"
	readonly property bool capsLock: keyboard?.capsLock ?? false
	readonly property string defaultKbLayout: keyboard?.layout.split(",")[0] ?? "??"
	property string desktopName: ""
	readonly property alias devices: extras.devices
	readonly property alias extras: extras
	readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
	readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
	property bool hadKeyboard
	readonly property string kbLayout: kbMap.get(kbLayoutFull) ?? "??"
	readonly property string kbLayoutFull: keyboard?.activeKeymap ?? "Unknown"
	readonly property var kbMap: new Map()
	readonly property HyprKeyboard keyboard: extras.devices.keyboards.find(kb => kb.main) ?? null
	readonly property var monitors: Hyprland.monitors
	readonly property bool numLock: keyboard?.numLock ?? false
	readonly property alias options: extras.options
	readonly property var toplevels: Hyprland.toplevels
	readonly property var workspaces: Hyprland.workspaces

	signal configReloaded

	function dispatch(request: string): void {
		Hyprland.dispatch(request);
	}

	function getActiveScreen(): ShellScreen {
		return Quickshell.screens.find(screen => root.monitorFor(screen) === root.focusedMonitor);
	}

	function monitorFor(screen: ShellScreen): HyprlandMonitor {
		return Hyprland.monitorFor(screen);
	}

	function reloadDynamicConfs(): void {
		extras.batchMessage(["keyword bindlni ,Caps_Lock,global,zshell:refreshDevices", "keyword bindlni ,Num_Lock,global,zshell:refreshDevices"]);
	}

	Component.onCompleted: reloadDynamicConfs()

	// function updateActiveWindow(): void {
	//     root.desktopName = root.applicationDir + root.activeToplevel?.lastIpcObject.class + ".desktop";
	// }

	Connections {
		function onRawEvent(event: HyprlandEvent): void {
			const n = event.name;
			if (n.endsWith("v2"))
				return;

			if (n === "configreloaded") {
				root.configReloaded();
				root.reloadDynamicConfs();
			} else if (["workspace", "moveworkspace", "activespecial", "focusedmon"].includes(n)) {
				Hyprland.refreshWorkspaces();
				Hyprland.refreshMonitors();
				// Qt.callLater( root.updateActiveWindow );
			} else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
				Hyprland.refreshToplevels();
				Hyprland.refreshWorkspaces();
				// Qt.callLater( root.updateActiveWindow );
			} else if (n.includes("mon")) {
				Hyprland.refreshMonitors();
				// Qt.callLater( root.updateActiveWindow );
			} else if (n.includes("workspace")) {
				Hyprland.refreshWorkspaces();
				// Qt.callLater( root.updateActiveWindow );
			} else if (n.includes("window") || n.includes("group") || ["pin", "fullscreen", "changefloatingmode", "minimize"].includes(n)) {
				Hyprland.refreshToplevels();
				// Qt.callLater( root.updateActiveWindow );
			}
		}

		target: Hyprland
	}

	FileView {
		id: desktopEntryName

		path: root.desktopName

		onLoaded: {
			const lines = text().split("\n");
			for (const line of lines) {
				if (line.startsWith("Name=")) {
					let name = line.replace("Name=", "");
					let caseFix = name[0].toUpperCase() + name.slice(1);
					root.activeName = caseFix;
					break;
				}
			}
		}
	}

	FileView {
		id: kbLayoutFile

		path: Quickshell.env("ZSHELL_XKB_RULES_PATH") || "/usr/share/X11/xkb/rules/base.lst"

		onLoaded: {
			const layoutMatch = text().match(/! layout\n([\s\S]*?)\n\n/);
			if (layoutMatch) {
				const lines = layoutMatch[1].split("\n");
				for (const line of lines) {
					if (!line.trim() || line.trim().startsWith("!"))
						continue;

					const match = line.match(/^\s*([a-z]{2,})\s+([a-zA-Z() ]+)$/);
					if (match)
						root.kbMap.set(match[2], match[1]);
				}
			}

			const variantMatch = text().match(/! variant\n([\s\S]*?)\n\n/);
			if (variantMatch) {
				const lines = variantMatch[1].split("\n");
				for (const line of lines) {
					if (!line.trim() || line.trim().startsWith("!"))
						continue;

					const match = line.match(/^\s*([a-zA-Z0-9_-]+)\s+([a-z]{2,}): (.+)$/);
					if (match)
						root.kbMap.set(match[3], match[2]);
				}
			}
		}
	}

	IpcHandler {
		function refreshDevices(): void {
			extras.refreshDevices();
		}

		target: "hypr"
	}

	CustomShortcut {
		name: "refreshDevices"

		onPressed: extras.refreshDevices()
		onReleased: extras.refreshDevices()
	}

	HyprExtras {
		id: extras

	}
}
