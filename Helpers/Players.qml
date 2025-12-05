pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
	id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
}
