import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Modules
import qs.Helpers as Helpers
import qs.Components

Item {
	required property Wrapper popouts
	required property RowLayout loader

    implicitWidth: timeText.contentWidth + 5 * 2
    anchors.top: parent.top
    anchors.bottom: parent.bottom

	CustomRect {
		anchors.fill: parent
		anchors.topMargin: 3
		anchors.bottomMargin: 3
		radius: 4
		color: "transparent"
		CustomText {
			id: timeText

			anchors.centerIn: parent

			text: Time.time
			color: Config.useDynamicColors ? DynamicColors.palette.m3tertiary : "white"

			Behavior on color {
				CAnim {}
			}
		}

		StateLayer {
			acceptedButtons: Qt.LeftButton
			onClicked: {
				if ( mouse.button === Qt.LeftButton && !visibilities.sidebar ) {
					Helpers.Calendar.displayYear = new Date().getFullYear();
					Helpers.Calendar.displayMonth = new Date().getMonth();
					root.popouts.currentName = "calendar";
					root.popouts.currentCenter = Qt.binding( () => item.mapToItem( root.loader, root.implicitWidth / 2, 0 ).x );
					root.popouts.hasCurrent = true;
				}
			}
		}
	}
}
