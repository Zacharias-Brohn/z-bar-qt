pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.UPower
import qs.Config
import qs.Components
import qs.Modules

Item {
	id: root

	required property var wrapper

	implicitWidth: profiles.implicitWidth
	implicitHeight: profiles.implicitHeight

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

        implicitWidth: saver.implicitHeight + balance.implicitHeight + perf.implicitHeight + 8 * 2 + saverLabel.contentWidth
        implicitHeight: Math.max(saver.implicitHeight, balance.implicitHeight, perf.implicitHeight) + 5 * 2 + saverLabel.contentHeight

        color: DynamicColors.tPalette.m3surfaceContainer
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

            anchors.top: parent.top
			anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 25

			text: "Power Saver"
            profile: PowerProfile.PowerSaver
            icon: "nest_eco_leaf"
        }

		CustomText {
			id: saverLabel
			anchors.top: saver.bottom
			anchors.horizontalCenter: saver.horizontalCenter
			text: saver.text
		}

        Profile {
            id: balance

            anchors.top: parent.top
			anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

			text: "Balanced"
            profile: PowerProfile.Balanced
            icon: "power_settings_new"
        }

		CustomText {
			id: balanceLabel
			anchors.top: balance.bottom
			anchors.horizontalCenter: balance.horizontalCenter
			text: balance.text
		}

        Profile {
            id: perf

            anchors.top: parent.top
			anchors.topMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 25

			text: "Performance"
            profile: PowerProfile.Performance
            icon: "bolt"
        }

		CustomText {
			id: perfLabel
			anchors.top: perf.bottom
			anchors.horizontalCenter: perf.horizontalCenter
			text: perf.text
		}
    }

    component Fill: AnchorChanges {
        required property Item item

        target: indicator
        anchors.left: item.left
        anchors.right: item.right
        anchors.top: item.top
        anchors.bottom: item.bottom
    }

	component Profile: Item {
        required property string icon
        required property int profile
		required property string text

        implicitWidth: icon.implicitHeight + 5 * 2
        implicitHeight: icon.implicitHeight + 5 * 2

        StateLayer {
            radius: 1000
            color: profiles.current === parent.icon ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface

            function onClicked(): void {
                PowerProfiles.profile = parent.profile;
            }
        }

        MaterialIcon {
            id: icon

            anchors.centerIn: parent

            text: parent.icon
            font.pointSize: 36
            color: profiles.current === text ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
            fill: profiles.current === text ? 1 : 0

            Behavior on fill {
                Anim {}
            }
        }
    }
}
