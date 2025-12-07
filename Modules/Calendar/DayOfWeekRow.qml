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
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: 30

            readonly property string dayName: {
                // Get the day name for this column
                const dayIndex = (index + Calendar.weekStartDay) % 7;
                return root.locale.dayName(dayIndex, Locale.ShortFormat);
            }

            CustomText {
                anchors.centerIn: parent

                text: parent.dayName
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: DynamicColors.palette.m3onSurfaceVariant
                opacity: 0.8
                font.weight: 500
                font.pointSize: 11
            }
        }
    }
}

