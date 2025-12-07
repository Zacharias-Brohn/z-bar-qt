pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

ColumnLayout {
    id: root

    spacing: 4

    readonly property var weekNumbers: Calendar.getWeekNumbers(Calendar.displayMonth, Calendar.displayYear)

    Repeater {
        model: ScriptModel {
			values: root.weekNumbers
		}

        Item {
            id: weekItem
            Layout.preferredHeight: 40
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignHCenter

            required property int index
            required property var modelData

            CustomText {
                id: weekText

                anchors.centerIn: parent

                text: weekItem.modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: DynamicColors.palette.m3onSurfaceVariant
                opacity: 0.5
                font.pointSize: 10
            }
        }
    }
}
