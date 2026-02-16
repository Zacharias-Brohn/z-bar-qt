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
            implicitHeight: weather.implicitHeight

            topLeftRadius: Appearance.rounding.large
            radius: Appearance.rounding.small
            color: DynamicColors.tPalette.m3surfaceContainer

            WeatherInfo {
                id: weather

                rootHeight: root.height
            }
        }

        CustomRect {
            Layout.fillWidth: true
            implicitHeight: resources.implicitHeight

            radius: Appearance.rounding.small
            color: DynamicColors.tPalette.m3surfaceContainer

            Resources {
				id: resources
			}
        }

        CustomClippingRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            bottomLeftRadius: Appearance.rounding.large
            radius: Appearance.rounding.small
            color: DynamicColors.tPalette.m3surfaceContainer

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
            Layout.fillWidth: true
            Layout.fillHeight: true

            topRightRadius: Appearance.rounding.large
            bottomRightRadius: Appearance.rounding.large
            radius: Appearance.rounding.small
            color: DynamicColors.tPalette.m3surfaceContainer

            NotifDock {
                lock: root.lock
            }
        }
    }
}
