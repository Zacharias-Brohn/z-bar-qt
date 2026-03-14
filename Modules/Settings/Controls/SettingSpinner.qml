import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property string name
	required property var object
	required property list<string> settings

	function commitChoice(choice: int, setting: string): void {
		root.object[setting] = choice;
		Config.save();
	}

	function formattedValue(setting: string): string {
		const value = root.object[setting];

		console.log(value);
		if (value === null || value === undefined)
			return "";

		return String(value);
	}

	function hourToAmPm(hour) {
		var h = Number(hour) % 24;
		var d = new Date(2000, 0, 1, h, 0, 0);
		return Qt.formatTime(d, "h AP");
	}

	Layout.fillWidth: true
	Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		ColumnLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true

			CustomText {
				id: text

				Layout.alignment: Qt.AlignLeft
				Layout.fillWidth: true
				font.pointSize: Appearance.font.size.larger
				text: root.name
			}

			CustomText {
				Layout.alignment: Qt.AlignLeft
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.normal
				text: qsTr("Dark mode will turn on at %1, and turn off at %2.").arg(root.hourToAmPm(root.object[root.settings[0]])).arg(root.hourToAmPm(root.object[root.settings[1]]))
			}
		}

		SpinnerButton {
			Layout.preferredHeight: Appearance.font.size.large + Appearance.padding.smaller * 2
			Layout.preferredWidth: height * 2
			currentIndex: root.object[root.settings[0]]
			text: root.formattedValue(root.settings[0])

			menu.onItemSelected: item => {
				root.commitChoice(item, root.settings[0]);
			}
		}

		SpinnerButton {
			Layout.preferredHeight: Appearance.font.size.large + Appearance.padding.smaller * 2
			Layout.preferredWidth: height * 2
			currentIndex: root.object[root.settings[1]]
			text: root.formattedValue(root.settings[1])

			menu.onItemSelected: item => {
				root.commitChoice(item, root.settings[1]);
			}
		}
	}
}
