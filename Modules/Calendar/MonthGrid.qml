pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers

GridLayout {
	id: root

	required property var locale
	required property Item wrapper

	columns: 7
	rowSpacing: 4
	columnSpacing: 4
	uniformCellWidths: true
	uniformCellHeights: true

	component Anim: NumberAnimation {
		target: root
		duration: MaterialEasing.expressiveEffectsTime
		easing.bezierCurve: MaterialEasing.expressiveEffects
	}

	Repeater {
		id: repeater
		model: ScriptModel {
			values: Calendar.getWeeksForMonth(Calendar.displayMonth, Calendar.displayYear)

			Behavior on values {
				SequentialAnimation {
					id: switchAnim
					ParallelAnimation {
						Anim {
							property: "opacity"
							from: 1.0
							to: 0.0
						}
						Anim {
							property: "scale"
							from: 1.0
							to: 0.8
						}
					}
					PropertyAction {}
					ParallelAnimation {
						Anim {
							property: "opacity"
							from: 0.0
							to: 1.0
						}
						Anim {
							property: "scale"
							from: 0.8
							to: 1.0
						}
					}
				}
			}
		}

		Rectangle {

			required property var modelData
			required property int index

			Layout.preferredWidth: 40
			Layout.preferredHeight: width


			radius: 1000
			color: {
				if (modelData.isToday) {
					console.log(width);
					return DynamicColors.palette.m3primaryContainer;
				}
				return "transparent";
			}

			Behavior on color {
				ColorAnimation { duration: 200 }
			}

			CustomText {
				anchors.centerIn: parent

				text: parent.modelData.day.toString()
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				opacity: parent.modelData.isCurrentMonth ? 1.0 : 0.4
				color: {
					if (parent.modelData.isToday) {
						return DynamicColors.palette.m3onPrimaryContainer;
					}
					return DynamicColors.palette.m3onSurface;
				}

				Behavior on color {
					ColorAnimation { duration: 200 }
				}
				Behavior on opacity {
					NumberAnimation { duration: 200 }
				}
			}

			StateLayer {
				color: DynamicColors.palette.m3onSurface
				onClicked: {
					console.log(`Selected date: ${parent.modelData.day}/${parent.modelData.month + 1}/${parent.modelData.year}`);
				}
			}
		}
	}
}
