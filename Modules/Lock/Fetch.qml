pragma ComponentBehavior: Bound

import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

ColumnLayout {
	id: root

	anchors.fill: parent
	anchors.margins: Appearance.padding.large * 2
	anchors.topMargin: Appearance.padding.large
	spacing: Appearance.spacing.small

	RowLayout {
		Layout.fillHeight: false
		Layout.fillWidth: true
		spacing: Appearance.spacing.normal

		CustomRect {
			color: DynamicColors.palette.m3primary
			implicitHeight: prompt.implicitHeight + Appearance.padding.normal * 2
			implicitWidth: prompt.implicitWidth + Appearance.padding.normal * 2
			radius: Appearance.rounding.small

			MonoText {
				id: prompt

				anchors.centerIn: parent
				color: DynamicColors.palette.m3onPrimary
				font.pointSize: root.width > 400 ? Appearance.font.size.larger : Appearance.font.size.normal
				text: ">"
			}
		}

		MonoText {
			Layout.fillWidth: true
			elide: Text.ElideRight
			font.pointSize: root.width > 400 ? Appearance.font.size.larger : Appearance.font.size.normal
			text: "caelestiafetch.sh"
		}

		WrappedLoader {
			Layout.fillHeight: true
			active: !iconLoader.active

			sourceComponent: OsLogo {
			}
		}
	}

	RowLayout {
		Layout.fillHeight: false
		Layout.fillWidth: true
		spacing: height * 0.15

		WrappedLoader {
			id: iconLoader

			Layout.fillHeight: true
			active: root.width > 320

			sourceComponent: OsLogo {
			}
		}

		ColumnLayout {
			Layout.bottomMargin: Appearance.padding.normal
			Layout.fillWidth: true
			Layout.leftMargin: iconLoader.active ? 0 : width * 0.1
			Layout.topMargin: Appearance.padding.normal
			spacing: Appearance.spacing.normal

			WrappedLoader {
				Layout.fillWidth: true
				active: !batLoader.active && root.height > 200

				sourceComponent: FetchText {
					text: `OS  : ${SystemInfo.osPrettyName || SysInfo.osName}`
				}
			}

			WrappedLoader {
				Layout.fillWidth: true
				active: root.height > (batLoader.active ? 200 : 110)

				sourceComponent: FetchText {
					text: `WM  : ${SystemInfo.wm}`
				}
			}

			WrappedLoader {
				Layout.fillWidth: true
				active: !batLoader.active || root.height > 110

				sourceComponent: FetchText {
					text: `USER: ${SystemInfo.user}`
				}
			}

			FetchText {
				text: `UP  : ${SystemInfo.uptime}`
			}

			WrappedLoader {
				id: batLoader

				Layout.fillWidth: true
				active: UPower.displayDevice.isLaptopBattery

				sourceComponent: FetchText {
					text: `BATT: ${[UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state) ? "(+) " : ""}${Math.round(UPower.displayDevice.percentage * 100)}%`
				}
			}
		}
	}

	WrappedLoader {
		Layout.alignment: Qt.AlignHCenter
		active: root.height > 180

		sourceComponent: RowLayout {
			spacing: Appearance.spacing.large

			Repeater {
				model: Math.max(0, Math.min(8, root.width / (Appearance.font.size.larger * 2 + Appearance.spacing.large)))

				CustomRect {
					required property int index

					color: DynamicColors.palette[`term${index}`]
					implicitHeight: Appearance.font.size.larger * 2
					implicitWidth: implicitHeight
					radius: Appearance.rounding.small
				}
			}
		}
	}

	component FetchText: MonoText {
		Layout.fillWidth: true
		elide: Text.ElideRight
		font.pointSize: root.width > 400 ? Appearance.font.size.larger : Appearance.font.size.normal
	}
	component MonoText: CustomText {
		font.family: Appearance.font.family.mono
	}
	component OsLogo: ColoredIcon {
		color: DynamicColors.palette.m3primary
		implicitSize: height
		layer.enabled: Config.lock.recolorLogo || SystemInfo.isDefaultLogo
		source: SystemInfo.osLogo
	}
	component WrappedLoader: Loader {
		visible: active
	}
}
