pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

RowLayout {
	spacing: 12

	Rectangle {
		Layout.preferredHeight: 40
		Layout.preferredWidth: 40
		color: "transparent"
		radius: 1000

		MaterialIcon {
			anchors.centerIn: parent
			color: DynamicColors.palette.m3onSurface
			fill: 1
			font.pointSize: 24
			text: "arrow_back_2"
		}

		StateLayer {
			onClicked: {
				if (Calendar.displayMonth === 0) {
					Calendar.displayMonth = 11;
					Calendar.displayYear -= 1;
				} else {
					Calendar.displayMonth -= 1;
				}
			}
		}
	}

	CustomText {
		Layout.fillWidth: true
		color: DynamicColors.palette.m3onSurface
		font.pointSize: 14
		font.weight: 600
		horizontalAlignment: Text.AlignHCenter
		text: new Date(Calendar.displayYear, Calendar.displayMonth, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
	}

	Rectangle {
		Layout.preferredHeight: 40
		Layout.preferredWidth: 40
		color: "transparent"
		radius: 1000

		MaterialIcon {
			anchors.centerIn: parent
			color: DynamicColors.palette.m3onSurface
			fill: 1
			font.pointSize: 24
			rotation: 180
			text: "arrow_back_2"
		}

		StateLayer {
			onClicked: {
				if (Calendar.displayMonth === 11) {
					Calendar.displayMonth = 0;
					Calendar.displayYear += 1;
				} else {
					Calendar.displayMonth += 1;
				}
			}
		}
	}
}
