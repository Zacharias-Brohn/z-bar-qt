pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config

CustomRect {
	id: root

	property alias active: splitButton.active
	property bool enabled: true
	property alias expanded: splitButton.expanded
	property int expandedZ: 100
	required property string label
	property alias menuItems: splitButton.menuItems
	property alias type: splitButton.type

	signal selected(item: MenuItem)

	Layout.fillWidth: true
	clip: false
	color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)
	implicitHeight: row.implicitHeight + Appearance.padding.large * 2
	opacity: enabled ? 1.0 : 0.5
	radius: Appearance.rounding.normal
	z: splitButton.menu.implicitHeight > 0 ? expandedZ : 1

	RowLayout {
		id: row

		anchors.fill: parent
		anchors.margins: Appearance.padding.large
		spacing: Appearance.spacing.normal

		CustomText {
			Layout.fillWidth: true
			color: root.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSurfaceVariant
			text: root.label
		}

		CustomSplitButton {
			id: splitButton

			enabled: root.enabled
			menu.z: 1
			type: CustomSplitButton.Filled

			menu.onItemSelected: item => {
				root.selected(item);
			}
			stateLayer.onClicked: {
				splitButton.expanded = !splitButton.expanded;
			}
		}
	}
}
