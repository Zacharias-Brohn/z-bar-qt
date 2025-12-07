pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

RowLayout {
	spacing: 12

	Rectangle {
		Layout.preferredWidth: 40
		Layout.preferredHeight: 40
		color: "transparent"
		radius: 1000

		MaterialIcon {
			anchors.centerIn: parent
			text: "arrow_back_2"
			fill: 1
			font.pointSize: 24
			color: DynamicColors.palette.m3onSurface
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
		text: new Date(Calendar.displayYear, Calendar.displayMonth, 1).toLocaleDateString(
			Qt.locale(),
			"MMMM yyyy"
		)
		font.weight: 600
		font.pointSize: 14
		color: DynamicColors.palette.m3onSurface
		Layout.fillWidth: true
		horizontalAlignment: Text.AlignHCenter
	}

	Rectangle {
		Layout.preferredWidth: 40
		Layout.preferredHeight: 40
		color: "transparent"
		radius: 1000

		MaterialIcon {
			anchors.centerIn: parent
			text: "arrow_back_2"
			fill: 1
			font.pointSize: 24
			rotation: 180
			color: DynamicColors.palette.m3onSurface
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
