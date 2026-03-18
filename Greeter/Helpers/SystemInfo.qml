pragma Singleton

import qs.Config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root

	property bool isDefaultLogo: true
	property string osId
	property list<string> osIdLike
	property string osLogo
	property string osName
	property string osPrettyName
	readonly property string shell: Quickshell.env("SHELL").split("/").pop()
	property string uptime
	readonly property string user: Quickshell.env("USER")
	readonly property string wm: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP")

	FileView {
		id: osRelease

		path: "/etc/os-release"

		onLoaded: {
			const lines = text().split("\n");

			const fd = key => lines.find(l => l.startsWith(`${key}=`))?.split("=")[1].replace(/"/g, "") ?? "";

			root.osName = fd("NAME");
			root.osPrettyName = fd("PRETTY_NAME");
			root.osId = fd("ID");
			root.osIdLike = fd("ID_LIKE").split(" ");

			const logo = Quickshell.iconPath(fd("LOGO"), true);
			if (Config.general.logo) {
				root.osLogo = Quickshell.iconPath(Config.general.logo, true) || "file://" + Paths.absolutePath(Config.general.logo);
				root.isDefaultLogo = false;
			} else if (logo) {
				root.osLogo = logo;
				root.isDefaultLogo = false;
			}
		}
	}

	Connections {
		function onLogoChanged(): void {
			osRelease.reload();
		}

		target: Config.general
	}

	Timer {
		interval: 15000
		repeat: true
		running: true

		onTriggered: fileUptime.reload()
	}

	FileView {
		id: fileUptime

		path: "/proc/uptime"

		onLoaded: {
			const up = parseInt(text().split(" ")[0] ?? 0);

			const hours = Math.floor(up / 3600);
			const minutes = Math.floor((up % 3600) / 60);

			let str = "";
			if (hours > 0)
				str += `${hours} hour${hours === 1 ? "" : "s"}`;
			if (minutes > 0 || !str)
				str += `${str ? ", " : ""}${minutes} minute${minutes === 1 ? "" : "s"}`;
			root.uptime = str;
		}
	}
}
