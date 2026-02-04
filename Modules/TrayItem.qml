import QtQuick.Layouts
import QtQuick.Effects
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Io
import Quickshell.Widgets
import qs.Modules
import qs.Components
import qs.Config

Item {
    id: root

    required property SystemTrayItem item
    required property PanelWindow bar
	required property int ind
	required property Wrapper popouts
	required property RowLayout loader
    property bool hasLoaded: false

	StateLayer {
		anchors.fill: parent
		anchors.margins: 3
		radius: 6
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: {
			if ( mouse.button === Qt.LeftButton ) {
				root.item.activate();
			} else if ( mouse.button === Qt.RightButton ) {
				if ( visibilities.sidebar ) {
					return;
				} else {
					root.popouts.currentName = `traymenu${ root.ind }`;
					root.popouts.currentCenter = Qt.binding( () => root.mapToItem( root.loader, root.implicitWidth / 2, 0 ).x );
					root.popouts.hasCurrent = true;
				}
			}
		}
	}

    Image {
        id: icon

        property bool batteryHDPI: root.bar.screen.x < 0 && root.item.icon.includes("battery")
        property bool nmHDPI: root.bar.screen.x < 0 && root.item.icon.includes("nm-")

        anchors.centerIn: parent
        width: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
        height: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
        source: root.item.icon
        mipmap: true
        smooth: ( batteryHDPI || nmHDPI ) ? false : true
        asynchronous: true
        sourceSize.width: ( batteryHDPI || nmHDPI ) ? 16 : 22
        sourceSize.height: ( batteryHDPI || nmHDPI ) ? 16 : 22
        fillMode: Image.PreserveAspectFit
    }
}
