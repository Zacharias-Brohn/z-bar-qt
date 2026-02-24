pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower
import qs.Config
import qs.Components
import qs.Modules

Item {
	id: root

	required property var wrapper

	implicitHeight: profiles.implicitHeight
	implicitWidth: profiles.implicitWidth

	CustomRect {
		id: profiles

		property string current: {
			const p = PowerProfiles.profile;
			if (p === PowerProfile.PowerSaver)
				return saver.icon;
			if (p === PowerProfile.Performance)
				return perf.icon;
			return balance.icon;
		}

		anchors.horizontalCenter: parent.horizontalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: Math.max(saver.implicitHeight, balance.implicitHeight, perf.implicitHeight) + 5 * 2 + saverLabel.contentHeight
		implicitWidth: saver.implicitHeight + balance.implicitHeight + perf.implicitHeight + 8 * 2 + saverLabel.contentWidth
		// color: "transparent"
		radius: 6

		CustomRect {
			id: indicator

			color: DynamicColors.palette.m3primary
			radius: 1000
			state: profiles.current

			states: [
				State {
					name: saver.icon

					Fill {
						item: saver
					}
				},
				State {
					name: balance.icon

					Fill {
						item: balance
					}
				},
				State {
					name: perf.icon

					Fill {
						item: perf
					}
				}
			]
			transitions: Transition {
				AnchorAnimation {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
					easing.type: Easing.BezierSpline
				}
			}
		}

		Profile {
			id: saver

			anchors.left: parent.left
			anchors.leftMargin: 25
			anchors.top: parent.top
			anchors.topMargin: 8
			icon: "nest_eco_leaf"
			profile: PowerProfile.PowerSaver
			text: "Power Saver"
		}

		CustomText {
			id: saverLabel

			anchors.horizontalCenter: saver.horizontalCenter
			anchors.top: saver.bottom
			font.bold: true
			text: saver.text
		}

		Profile {
			id: balance

			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: parent.top
			anchors.topMargin: 8
			icon: "power_settings_new"
			profile: PowerProfile.Balanced
			text: "Balanced"
		}

		CustomText {
			id: balanceLabel

			anchors.horizontalCenter: balance.horizontalCenter
			anchors.top: balance.bottom
			font.bold: true
			text: balance.text
		}

		Profile {
			id: perf

			anchors.right: parent.right
			anchors.rightMargin: 25
			anchors.top: parent.top
			anchors.topMargin: 8
			icon: "bolt"
			profile: PowerProfile.Performance
			text: "Performance"
		}

		CustomText {
			id: perfLabel

			anchors.horizontalCenter: perf.horizontalCenter
			anchors.top: perf.bottom
			font.bold: true
			text: perf.text
		}
	}

	component Fill: AnchorChanges {
		required property Item item

		anchors.bottom: item.bottom
		anchors.left: item.left
		anchors.right: item.right
		anchors.top: item.top
		target: indicator
	}
	component Profile: Item {
		required property string icon
		required property int profile
		required property string text

		implicitHeight: icon.implicitHeight + 5 * 2
		implicitWidth: icon.implicitHeight + 5 * 2

		StateLayer {
			function onClicked(): void {
				PowerProfiles.profile = parent.profile;
			}

			color: profiles.current === parent.icon ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			radius: 1000
		}

		MaterialIcon {
			id: icon

			anchors.centerIn: parent
			color: profiles.current === text ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
			fill: profiles.current === text ? 1 : 0
			font.pointSize: 36
			text: parent.icon

			Behavior on fill {
				Anim {
				}
			}
		}
	}
}
