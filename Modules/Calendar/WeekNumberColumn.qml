pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

ColumnLayout {
	id: root

	readonly property var weekNumbers: Calendar.getWeekNumbers(Calendar.displayMonth, Calendar.displayYear)

	spacing: 4

	Repeater {
		model: ScriptModel {
			values: root.weekNumbers
		}

		Item {
			id: weekItem

			required property int index
			required property var modelData

			Layout.alignment: Qt.AlignHCenter
			Layout.preferredHeight: 40
			Layout.preferredWidth: 20

			CustomText {
				id: weekText

				anchors.centerIn: parent
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 10
				horizontalAlignment: Text.AlignHCenter
				opacity: 0.5
				text: weekItem.modelData
				verticalAlignment: Text.AlignVCenter
			}
		}
	}
}
