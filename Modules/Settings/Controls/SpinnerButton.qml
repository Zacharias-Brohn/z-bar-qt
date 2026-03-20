import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

CustomRect {
	id: root

	property alias currentIndex: menu.currentIndex
	property bool enabled
	property alias expanded: menu.expanded
	property alias label: label
	property alias menu: menu
	property alias text: label.text

	color: enabled ? DynamicColors.palette.m3primary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
	radius: Appearance.rounding.full
	z: expanded ? 100 : 0

	CustomText {
		id: label

		anchors.centerIn: parent
		color: root.enabled ? DynamicColors.palette.m3onPrimary : DynamicColors.layer(DynamicColors.palette.m3onSurface, 2)
		font.pointSize: Appearance.font.size.large
	}

	StateLayer {
		function onClicked(): void {
			SettingsDropdowns.toggle(menu, root);
		}

		visible: root.enabled
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
