import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers as Helpers

Item {
	id: root

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: layout.childrenRect.width + 10 * 2

	CustomRect {
		anchors.bottomMargin: 4
		anchors.fill: parent
		anchors.topMargin: 4
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: 1000
	}

	RowLayout {
		id: layout

		anchors.centerIn: parent

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			animate: true
			color: !Helpers.UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3error
			fill: 1
			text: {
				if (!Helpers.UPower.displayDevice.isLaptopBattery) {
					if (PowerProfiles.profile === PowerProfile.PowerSaver)
						return "nest_eco_leaf";
					if (PowerProfiles.profile === PowerProfile.Performance)
						return "bolt";
					return "power_settings_new";
				}

				const perc = Helpers.UPower.displayDevice.percentage;
				const charging = [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(Helpers.UPower.displayDevice.state);
				if (perc === 1)
					return charging ? "battery_charging_full" : "battery_full";
				let level = Math.floor(perc * 7);
				if (charging && (level === 4 || level === 1))
					level--;
				return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
			}
		}

		CustomText {
			Layout.alignment: Qt.AlignVCenter
			text: Helpers.UPower.displayDevice.isLaptopBattery ? qsTr("%1%").arg(Math.round(UPower.displayDevice.percentage * 100)) : (PowerProfiles.profile === PowerProfile.PowerSaver ? qsTr("Pwr Sav") : PowerProfiles.profile === PowerProfile.Performance ? qsTr("Perf") : qsTr("Bal"))
		}
	}
}
