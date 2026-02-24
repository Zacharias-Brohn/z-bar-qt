import QtQuick.Layouts
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Modules
import qs.Components
import qs.Config

Item {
	id: root

	required property PanelWindow bar
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

	// Image {
	//     id: icon
	//
	//     property bool batteryHDPI: root.bar.screen.x < 0 && root.item.icon.includes("battery")
	//     property bool nmHDPI: root.bar.screen.x < 0 && root.item.icon.includes("nm-")
	//
	//     anchors.centerIn: parent
	//     width: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
	//     height: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
	//     source: root.item.icon
	//     mipmap: true
	//     smooth: ( batteryHDPI || nmHDPI ) ? false : true
	//     asynchronous: true
	//     sourceSize.width: ( batteryHDPI || nmHDPI ) ? 16 : 22
	//     sourceSize.height: ( batteryHDPI || nmHDPI ) ? 16 : 22
	//     fillMode: Image.PreserveAspectFit
	// }
}
