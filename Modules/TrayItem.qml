import QtQuick.Layouts
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Modules
import qs.Components
import qs.Config

Item {
	id: root

	property bool hasLoaded: false
	required property int ind
	required property SystemTrayItem item
	required property RowLayout loader
	required property Wrapper popouts

	StateLayer {
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		anchors.fill: parent
		anchors.margins: 3
		radius: 6

		onClicked: {
			if (mouse.button === Qt.LeftButton) {
				root.item.activate();
			} else if (mouse.button === Qt.RightButton) {
				root.popouts.currentName = `traymenu${root.ind}`;
				root.popouts.currentCenter = Qt.binding(() => root.mapToItem(root.loader, root.implicitWidth / 2, 0).x);
				root.popouts.hasCurrent = true;
				if (visibilities.sidebar || visibilities.dashboard) {
					visibilities.sidebar = false;
					visibilities.dashboard = false;
				}
			}
		}
	}

	ColoredIcon {
		id: icon

		anchors.centerIn: parent
		color: DynamicColors.palette.m3onSurface
		implicitSize: 22
		layer.enabled: DynamicColors.light
		source: root.item.icon
	}
}
