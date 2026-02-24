pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQml
import ZShell
import qs.Config
import qs.Components

Singleton {
	id: root

	readonly property MprisPlayer active: props.manualActive ?? list.find(p => getIdentity(p) === Config.services.defaultPlayer) ?? list[0] ?? null
	readonly property list<MprisPlayer> list: Mpris.players.values
	property alias manualActive: props.manualActive

	function getIdentity(player: MprisPlayer): string {
		const alias = Config.services.playerAliases.find(a => a.from === player.identity);
		return alias?.to ?? player.identity;
	}

	Connections {
		function onPostTrackChanged() {
			if (!Config.utilities.toasts.nowPlaying) {
				return;
			}
		}

		target: active
	}

	PersistentProperties {
		id: props

		property MprisPlayer manualActive

		reloadableId: "players"
	}

	CustomShortcut {
		description: "Toggle media playback"
		name: "mediaToggle"

		onPressed: {
			const active = root.active;
			if (active && active.canTogglePlaying)
				active.togglePlaying();
		}
	}

	CustomShortcut {
		description: "Previous track"
		name: "mediaPrev"

		onPressed: {
			const active = root.active;
			if (active && active.canGoPrevious)
				active.previous();
		}
	}

	CustomShortcut {
		description: "Next track"
		name: "mediaNext"

		onPressed: {
			const active = root.active;
			if (active && active.canGoNext)
				active.next();
		}
	}

	CustomShortcut {
		description: "Stop media playback"
		name: "mediaStop"

		onPressed: root.active?.stop()
	}

	IpcHandler {
		function getActive(prop: string): string {
			const active = root.active;
			return active ? active[prop] ?? "Invalid property" : "No active player";
		}

		function list(): string {
			return root.list.map(p => root.getIdentity(p)).join("\n");
		}

		function next(): void {
			const active = root.active;
			if (active?.canGoNext)
				active.next();
		}

		function pause(): void {
			const active = root.active;
			if (active?.canPause)
				active.pause();
		}

		function play(): void {
			const active = root.active;
			if (active?.canPlay)
				active.play();
		}

		function playPause(): void {
			const active = root.active;
			if (active?.canTogglePlaying)
				active.togglePlaying();
		}

		function previous(): void {
			const active = root.active;
			if (active?.canGoPrevious)
				active.previous();
		}

		function stop(): void {
			root.active?.stop();
		}

		target: "mpris"
	}
}
