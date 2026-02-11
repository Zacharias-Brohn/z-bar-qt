import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config
import qs.Helpers as Helpers
import qs.Modules

Item {
	id: root

	implicitWidth: layout.childrenRect.width
	anchors.top: parent.top
	anchors.bottom: parent.bottom

	RowLayout {
		id: layout
		anchors.centerIn: parent

		MaterialIcon {
			animate: true
			Layout.alignment: Qt.AlignVCenter
			text: {
				if (!Helpers.UPower.displayDevice.isLaptopBattery) {
					if (PowerProfiles.profile === PowerProfile.PowerSaver)
						return "energy_savings_leaf";
					if (PowerProfiles.profile === PowerProfile.Performance)
						return "rocket_launch";
					return "balance";
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
			color: !Helpers.UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3error
			fill: 1
		}

		CustomText {
			Layout.alignment: Qt.AlignVCenter
			text: Helpers.UPower.displayDevice.isLaptopBattery ? qsTr("%1%").arg(Math.round(UPower.displayDevice.percentage * 100)) : qsTr("NaN")
		}
	}
}
