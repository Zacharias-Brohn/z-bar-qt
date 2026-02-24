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

	columnSpacing: 4
	columns: 7
	rowSpacing: 4
	uniformCellHeights: true
	uniformCellWidths: true

	Repeater {
		id: repeater

		model: ScriptModel {
			values: Calendar.getWeeksForMonth(Calendar.displayMonth, Calendar.displayYear)

			Behavior on values {
				SequentialAnimation {
					id: switchAnim

					ParallelAnimation {
						Anim {
							from: 1.0
							property: "opacity"
							to: 0.0
						}

						Anim {
							from: 1.0
							property: "scale"
							to: 0.8
						}
					}

					PropertyAction {
					}

					ParallelAnimation {
						Anim {
							from: 0.0
							property: "opacity"
							to: 1.0
						}

						Anim {
							from: 0.8
							property: "scale"
							to: 1.0
						}
					}
				}
			}
		}

		Rectangle {
			required property int index
			required property var modelData

			Layout.preferredHeight: width
			Layout.preferredWidth: 40
			color: {
				if (modelData.isToday) {
					console.log(width);
					return DynamicColors.palette.m3primaryContainer;
				}
				return "transparent";
			}
			radius: 1000

			Behavior on color {
				ColorAnimation {
					duration: 200
				}
			}

			CustomText {
				anchors.centerIn: parent
				color: {
					if (parent.modelData.isToday) {
						return DynamicColors.palette.m3onPrimaryContainer;
					}
					return DynamicColors.palette.m3onSurface;
				}
				horizontalAlignment: Text.AlignHCenter
				opacity: parent.modelData.isCurrentMonth ? 1.0 : 0.4
				text: parent.modelData.day.toString()
				verticalAlignment: Text.AlignVCenter

				Behavior on color {
					ColorAnimation {
						duration: 200
					}
				}
				Behavior on opacity {
					NumberAnimation {
						duration: 200
					}
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

	component Anim: NumberAnimation {
		duration: MaterialEasing.expressiveEffectsTime
		easing.bezierCurve: MaterialEasing.expressiveEffects
		target: root
	}
}
