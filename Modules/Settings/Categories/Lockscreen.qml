import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Modules.Settings.Categories.Lockscreen
import qs.Config
import qs.Helpers

CustomFlickable {
	id: root

	contentHeight: clayout.implicitHeight

	TapHandler {
		acceptedButtons: Qt.LeftButton

		onTapped: function (eventPoint) {
			const menu = SettingsDropdowns.activeMenu;
			if (!menu)
				return;

			const p = eventPoint.scenePosition;

			if (SettingsDropdowns.hit(SettingsDropdowns.activeTrigger, p))
				return;

			if (SettingsDropdowns.hit(menu, p))
				return;

			SettingsDropdowns.closeActive();
		}
	}

	ColumnLayout {
		id: clayout

		anchors.fill: parent

		CustomRect {
			Layout.fillWidth: true
			Layout.preferredHeight: idleLayout.implicitHeight + Appearance.padding.normal * 2
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.normal - Appearance.padding.smaller
			z: -1

			Idle {
				id: idleLayout

				anchors.left: parent.left
				anchors.margins: Appearance.padding.large
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
			}
		}
	}

	component Settings: CustomRect {
		id: settingsItem

		required property string name

		Layout.preferredHeight: 60
		Layout.preferredWidth: 200

		CustomText {
			id: text

			anchors.fill: parent
			font.bold: true
			font.pointSize: Appearance.font.size.large * 2
			text: settingsItem.name
			verticalAlignment: Text.AlignVCenter
		}
	}
}
