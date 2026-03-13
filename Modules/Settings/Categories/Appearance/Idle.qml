import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Modules.Settings.Controls

ColumnLayout {
	id: root

	function addTimeoutEntry() {
		let list = [...Config.general.idle.timeouts];

		list.push({
			name: "New Entry",
			timeout: 600,
			idleAction: "lock"
		});

		Config.general.idle.timeouts = list;
		Config.save();
	}

	function updateTimeoutEntry(i, key, value) {
		const list = [...Config.general.idle.timeouts];
		let entry = list[i];

		entry[key] = value;
		list[i] = entry;

		Config.general.idle.timeouts = list;
		Config.save();
	}

	Layout.fillWidth: true
	spacing: Appearance.spacing.smaller

	Repeater {
		model: Config.general.idle.timeouts

		SettingList {
			Layout.fillWidth: true

			onAddActiveActionRequested: {
				root.updateTimeoutEntry(index, "activeAction", "");
			}
			onFieldEdited: function (key, value) {
				root.updateTimeoutEntry(index, key, value);
			}
		}
	}

	CustomButton {
		text: qsTr("Add timeout entry")

		onClicked: root.addTimeoutEntry()
	}
}
