import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

CustomRect {
	id: root

	property alias currentIndex: menu.currentIndex
	property alias expanded: menu.expanded
	property alias label: label
	property alias menu: menu
	property alias text: label.text

	color: DynamicColors.palette.m3primary
	radius: Appearance.rounding.full

	CustomText {
		id: label

		anchors.centerIn: parent
		color: DynamicColors.palette.m3onPrimary
		font.pointSize: Appearance.font.size.large
	}

	StateLayer {
		function onClicked(): void {
			SettingsDropdowns.toggle(menu, root);
		}
	}

	PathViewMenu {
		id: menu

		anchors.centerIn: parent
		from: 1
		implicitWidth: root.width
		itemHeight: root.height
		to: 24
	}
}
