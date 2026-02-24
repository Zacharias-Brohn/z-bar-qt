pragma Singleton

import ZShell
import Quickshell
import qs.Config

Singleton {
	id: root

	readonly property string cache: `${Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`}/zshell`
	readonly property string config: `${Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`}/zshell`
	readonly property string data: `${Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`}/zshell`
	readonly property string home: Quickshell.env("HOME")
	readonly property string imagecache: `${cache}/imagecache`
	readonly property string libdir: Quickshell.env("ZSHELL_LIB_DIR") || "/usr/lib/zshell"
	readonly property string notifimagecache: `${imagecache}/notifs`
	readonly property string pictures: Quickshell.env("XDG_PICTURES_DIR") || `${home}/Pictures`
	readonly property string recsdir: Quickshell.env("ZSHELL_RECORDINGS_DIR") || `${videos}/Recordings`
	readonly property string state: `${Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`}/zshell`
	readonly property string videos: Quickshell.env("XDG_VIDEOS_DIR") || `${home}/Videos`
	readonly property string wallsdir: Quickshell.env("ZSHELL_WALLPAPERS_DIR") || absolutePath(Config.wallpaperPath)

	function absolutePath(path: string): string {
		return toLocalFile(path.replace("~", home));
	}

	function shortenHome(path: string): string {
		return path.replace(home, "~");
	}

	function toLocalFile(path: url): string {
		path = Qt.resolvedUrl(path);
		return path.toString() ? ZShellIo.toLocalFile(path) : "";
	}
}
