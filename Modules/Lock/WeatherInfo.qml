pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

ColumnLayout {
	id: root

	required property int rootHeight

	anchors.left: parent.left
	anchors.margins: Appearance.padding.large * 2
	anchors.right: parent.right
	spacing: Appearance.spacing.small

	Loader {
		Layout.alignment: Qt.AlignHCenter
		Layout.bottomMargin: -Appearance.padding.large
		Layout.topMargin: Appearance.padding.large * 2
		active: root.rootHeight > 610
		visible: active

		sourceComponent: CustomText {
			color: DynamicColors.palette.m3primary
			font.pointSize: Appearance.font.size.extraLarge
			font.weight: 500
			text: qsTr("Weather")
		}
	}

	RowLayout {
		Layout.fillWidth: true
		spacing: Appearance.spacing.large

		MaterialIcon {
			animate: true
			color: DynamicColors.palette.m3secondary
			font.pointSize: Appearance.font.size.extraLarge * 2.5
			text: Weather.icon
		}

		ColumnLayout {
			spacing: Appearance.spacing.small

			CustomText {
				Layout.fillWidth: true
				animate: true
				color: DynamicColors.palette.m3secondary
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.large
				font.weight: 500
				text: Weather.description
			}

			CustomText {
				Layout.fillWidth: true
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.normal
				text: qsTr("Humidity: %1%").arg(Weather.humidity)
			}
		}

		Loader {
			Layout.rightMargin: Appearance.padding.smaller
			active: root.width > 400
			visible: active

			sourceComponent: ColumnLayout {
				spacing: Appearance.spacing.small

				CustomText {
					Layout.fillWidth: true
					animate: true
					color: DynamicColors.palette.m3primary
					elide: Text.ElideLeft
					font.pointSize: Appearance.font.size.extraLarge
					font.weight: 500
					horizontalAlignment: Text.AlignRight
					text: Weather.temp
				}

				CustomText {
					Layout.fillWidth: true
					animate: true
					color: DynamicColors.palette.m3outline
					elide: Text.ElideLeft
					font.pointSize: Appearance.font.size.smaller
					horizontalAlignment: Text.AlignRight
					text: qsTr("Feels like: %1").arg(Weather.feelsLike)
				}
			}
		}
	}

	Loader {
		id: forecastLoader

		Layout.bottomMargin: Appearance.padding.large * 2
		Layout.fillWidth: true
		Layout.topMargin: Appearance.spacing.smaller
		active: root.rootHeight > 820
		visible: active

		sourceComponent: RowLayout {
			spacing: Appearance.spacing.large

			Repeater {
				model: {
					const forecast = Weather.hourlyForecast;
					const count = root.width < 320 ? 3 : root.width < 400 ? 4 : 5;
					if (!forecast)
						return Array.from({
							length: count
						}, () => null);

					return forecast.slice(0, count);
				}

				ColumnLayout {
					id: forecastHour

					required property var modelData

					Layout.fillWidth: true
					spacing: Appearance.spacing.small

					CustomText {
						Layout.fillWidth: true
						color: DynamicColors.palette.m3outline
						font.pointSize: Appearance.font.size.larger
						horizontalAlignment: Text.AlignHCenter
						text: {
							const hour = forecastHour.modelData?.hour ?? 0;
							return hour > 12 ? `${(hour - 12).toString().padStart(2, "0")} PM` : `${hour.toString().padStart(2, "0")} AM`;
						}
					}

					MaterialIcon {
						Layout.alignment: Qt.AlignHCenter
						font.pointSize: Appearance.font.size.extraLarge * 1.5
						font.weight: 500
						text: forecastHour.modelData?.icon ?? "cloud_alert"
					}

					CustomText {
						Layout.alignment: Qt.AlignHCenter
						color: DynamicColors.palette.m3secondary
						font.pointSize: Appearance.font.size.larger
						text: Config.services.useFahrenheit ? `${forecastHour.modelData?.tempF ?? 0}°F` : `${forecastHour.modelData?.tempC ?? 0}°C`
					}
				}
			}
		}
	}

	Timer {
		interval: 900000 // 15 minutes
		repeat: true
		running: true
		triggeredOnStart: true

		onTriggered: Weather.reload()
	}
}
