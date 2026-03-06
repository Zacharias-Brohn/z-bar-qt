import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

RowLayout {
	id: root

	required property var lock

	spacing: Appearance.spacing.large * 2

	ColumnLayout {
		Layout.fillWidth: true
		spacing: Appearance.spacing.normal

		CustomRect {
			Layout.fillWidth: true
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitHeight: weather.implicitHeight
			radius: Appearance.rounding.small
			topLeftRadius: Appearance.rounding.large

			WeatherInfo {
				id: weather

				rootHeight: root.height
			}
		}

		CustomRect {
			Layout.fillWidth: true
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitHeight: resources.implicitHeight
			radius: Appearance.rounding.small

			Resources {
				id: resources

			}
		}

		CustomClippingRect {
			Layout.fillHeight: true
			Layout.fillWidth: true
			bottomLeftRadius: Appearance.rounding.large
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.small

			Media {
				id: media

				lock: root.lock
			}
		}
	}

	Center {
		lock: root.lock
	}

	ColumnLayout {
		Layout.fillWidth: true
		spacing: Appearance.spacing.normal

		CustomRect {
			Layout.fillHeight: true
			Layout.fillWidth: true
			bottomRightRadius: Appearance.rounding.large
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.small
			topRightRadius: Appearance.rounding.large

			NotifDock {
				lock: root.lock
			}
		}
	}
}
