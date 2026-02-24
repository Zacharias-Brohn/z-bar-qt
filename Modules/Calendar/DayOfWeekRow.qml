pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

RowLayout {
	id: root

	required property var locale

	spacing: 4

	Repeater {
		model: 7

		Item {
			readonly property string dayName: {
				// Get the day name for this column
				const dayIndex = (index + Calendar.weekStartDay) % 7;
				return root.locale.dayName(dayIndex, Locale.ShortFormat);
			}
			required property int index

			Layout.fillWidth: true
			Layout.preferredHeight: 30

			CustomText {
				anchors.centerIn: parent
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 11
				font.weight: 500
				horizontalAlignment: Text.AlignHCenter
				opacity: 0.8
				text: parent.dayName
				verticalAlignment: Text.AlignVCenter
			}
		}
	}
}
