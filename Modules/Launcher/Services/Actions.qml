pragma Singleton

import qs.Modules.Launcher
import qs.Helpers
import qs.Config
import Quickshell
import QtQuick

Searcher {
	id: root

	function transformSearch(search: string): string {
		return search.slice(Config.launcher.actionPrefix.length);
	}

	list: variants.instances
	useFuzzy: Config.launcher.useFuzzy.actions

	Variants {
		id: variants

		model: Config.launcher.actions.filter(a => (a.enabled ?? true))

		Action {
		}
	}

	component Action: QtObject {
		readonly property list<string> command: modelData.command ?? []
		readonly property bool dangerous: modelData.dangerous ?? false
		readonly property string desc: modelData.description ?? qsTr("No description")
		readonly property bool enabled: modelData.enabled ?? true
		readonly property string icon: modelData.icon ?? "help_outline"
		required property var modelData
		readonly property string name: modelData.name ?? qsTr("Unnamed")

		function onClicked(list: AppList): void {
			if (command.length === 0)
				return;

			if (command[0] === "autocomplete" && command.length > 1) {
				list.search.text = `${Config.launcher.actionPrefix}${command[1]} `;
			} else if (command[0] === "setMode" && command.length > 1) {
				list.visibilities.launcher = false;
				Colours.setMode(command[1]);
			} else {
				list.visibilities.launcher = false;
				Quickshell.execDetached(command);
			}
		}
	}
}
