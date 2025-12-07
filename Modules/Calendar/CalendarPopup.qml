pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	required property Item wrapper

	implicitWidth: layout.childrenRect.width + layout.anchors.margins * 2
	implicitHeight: layout.childrenRect.height + layout.anchors.margins * 2

	ColumnLayout {
		id: layout

		anchors.centerIn: parent
		anchors.margins: 16
		spacing: 16

		// Header with month/year and navigation
		CalendarHeader {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height
		}

		// Calendar grid
		RowLayout {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height
			spacing: 12

			ColumnLayout {
				Layout.alignment: Qt.AlignTop
				Layout.preferredHeight: childrenRect.height
				Layout.preferredWidth: weekNumberColumn.width
				spacing: 8

				Item {
					Layout.preferredHeight: dayOfWeekRow.height
				}

				WeekNumberColumn {
					id: weekNumberColumn

					Layout.alignment: Qt.AlignTop
					Layout.preferredHeight: weekNumbers.values.length * 44
				}
			}

			ColumnLayout {
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.preferredHeight: childrenRect.height
				spacing: 8

				DayOfWeekRow {
					id: dayOfWeekRow
					locale: Qt.locale()
					Layout.fillWidth: true
					Layout.preferredHeight: 30
				}

				MonthGrid {
					locale: Qt.locale()

					wrapper: root.wrapper
					Layout.preferredWidth: childrenRect.width
					Layout.preferredHeight: childrenRect.height
				}
			}
		}
	}
}
