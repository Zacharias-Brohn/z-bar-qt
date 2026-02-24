pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules

CustomMouseArea {
	id: root

	readonly property int currMonth: state.currentDate.getMonth()
	readonly property int currYear: state.currentDate.getFullYear()
	required property var state

	function onWheel(event: WheelEvent): void {
		if (event.angleDelta.y > 0)
			root.state.currentDate = new Date(root.currYear, root.currMonth - 1, 1);
		else if (event.angleDelta.y < 0)
			root.state.currentDate = new Date(root.currYear, root.currMonth + 1, 1);
	}

	acceptedButtons: Qt.MiddleButton
	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: inner.implicitHeight + inner.anchors.margins * 2

	onClicked: root.state.currentDate = new Date()

	ColumnLayout {
		id: inner

		anchors.fill: parent
		anchors.margins: Appearance.padding.large
		spacing: Appearance.spacing.small

		RowLayout {
			id: monthNavigationRow

			Layout.fillWidth: true
			spacing: Appearance.spacing.small

			Item {
				implicitHeight: prevMonthText.implicitHeight + Appearance.padding.small * 2
				implicitWidth: implicitHeight

				StateLayer {
					id: prevMonthStateLayer

					function onClicked(): void {
						root.state.currentDate = new Date(root.currYear, root.currMonth - 1, 1);
					}

					radius: Appearance.rounding.full
				}

				MaterialIcon {
					id: prevMonthText

					anchors.centerIn: parent
					color: DynamicColors.palette.m3tertiary
					font.pointSize: Appearance.font.size.normal
					font.weight: 700
					text: "chevron_left"
				}
			}

			Item {
				Layout.fillWidth: true
				implicitHeight: monthYearDisplay.implicitHeight + Appearance.padding.small * 2
				implicitWidth: monthYearDisplay.implicitWidth + Appearance.padding.small * 2

				StateLayer {
					function onClicked(): void {
						root.state.currentDate = new Date();
					}

					anchors.fill: monthYearDisplay
					anchors.leftMargin: -Appearance.padding.normal
					anchors.margins: -Appearance.padding.small
					anchors.rightMargin: -Appearance.padding.normal
					disabled: {
						const now = new Date();
						return root.currMonth === now.getMonth() && root.currYear === now.getFullYear();
					}
					radius: Appearance.rounding.full
				}

				CustomText {
					id: monthYearDisplay

					anchors.centerIn: parent
					color: DynamicColors.palette.m3primary
					font.capitalization: Font.Capitalize
					font.pointSize: Appearance.font.size.normal
					font.weight: 500
					text: grid.title
				}
			}

			Item {
				implicitHeight: nextMonthText.implicitHeight + Appearance.padding.small * 2
				implicitWidth: implicitHeight

				StateLayer {
					id: nextMonthStateLayer

					function onClicked(): void {
						root.state.currentDate = new Date(root.currYear, root.currMonth + 1, 1);
					}

					radius: Appearance.rounding.full
				}

				MaterialIcon {
					id: nextMonthText

					anchors.centerIn: parent
					color: DynamicColors.palette.m3tertiary
					font.pointSize: Appearance.font.size.normal
					font.weight: 700
					text: "chevron_right"
				}
			}
		}

		DayOfWeekRow {
			id: daysRow

			Layout.fillWidth: true
			locale: grid.locale

			delegate: CustomText {
				required property var model

				color: (model.day === 0) ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3onSurfaceVariant
				font.weight: 500
				horizontalAlignment: Text.AlignHCenter
				text: model.shortName
			}
		}

		Item {
			Layout.fillWidth: true
			implicitHeight: grid.implicitHeight

			MonthGrid {
				id: grid

				anchors.fill: parent
				locale: Qt.locale("en_SE")
				month: root.currMonth
				spacing: 3
				year: root.currYear

				delegate: Item {
					id: dayItem

					required property var model

					implicitHeight: text.implicitHeight + Appearance.padding.small * 2
					implicitWidth: implicitHeight

					CustomText {
						id: text

						anchors.centerIn: parent
						color: {
							const dayOfWeek = dayItem.model.date.getUTCDay();
							if (dayOfWeek === 6)
								return DynamicColors.palette.m3secondary;

							return DynamicColors.palette.m3onSurfaceVariant;
						}
						font.pointSize: Appearance.font.size.normal
						font.weight: 500
						horizontalAlignment: Text.AlignHCenter
						opacity: dayItem.model.today || dayItem.model.month === grid.month ? 1 : 0.4
						text: grid.locale.toString(dayItem.model.day)
					}
				}
			}

			CustomRect {
				id: todayIndicator

				property Item today
				readonly property Item todayItem: grid.contentItem.children.find(c => c.model.today) ?? null

				clip: true
				color: DynamicColors.palette.m3primary
				implicitHeight: today?.implicitHeight ?? 0
				implicitWidth: today?.implicitWidth ?? 0
				opacity: todayItem ? 1 : 0
				radius: Appearance.rounding.full
				scale: todayItem ? 1 : 0.7
				x: today ? today.x + (today.width - implicitWidth) / 2 : 0
				y: today?.y ?? 0

				Behavior on opacity {
					Anim {
					}
				}
				Behavior on scale {
					Anim {
					}
				}
				Behavior on x {
					Anim {
						duration: Appearance.anim.durations.expressiveDefaultSpatial
						easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					}
				}
				Behavior on y {
					Anim {
						duration: Appearance.anim.durations.expressiveDefaultSpatial
						easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					}
				}

				onTodayItemChanged: {
					if (todayItem)
						today = todayItem;
				}

				Coloriser {
					colorizationColor: DynamicColors.palette.m3onPrimary
					implicitHeight: grid.height
					implicitWidth: grid.width
					source: grid
					sourceColor: DynamicColors.palette.m3onSurface
					x: -todayIndicator.x
					y: -todayIndicator.y
				}
			}
		}
	}
}
