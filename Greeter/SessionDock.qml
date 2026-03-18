pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Helpers
import qs.Config

ColumnLayout {
	id: root

	required property var greeter

	anchors.fill: parent
	anchors.margins: Appearance.padding.large
	spacing: Appearance.spacing.smaller

	CustomText {
		Layout.fillWidth: true
		color: DynamicColors.palette.m3outline
		elide: Text.ElideRight
		font.family: Appearance.font.family.mono
		font.weight: 500
		text: root.greeter.sessions.length > 0 ? qsTr("%1 session%2").arg(root.greeter.sessions.length).arg(root.greeter.sessions.length === 1 ? "" : "s") : qsTr("Sessions")
	}

	CustomClippingRect {
		Layout.fillHeight: true
		Layout.fillWidth: true
		color: "transparent"
		radius: Appearance.rounding.small

		Loader {
			active: opacity > 0
			anchors.centerIn: parent
			opacity: root.greeter.sessions.length > 0 ? 0 : 1

			Behavior on opacity {
				Anim {
					duration: Appearance.anim.durations.extraLarge
				}
			}
			sourceComponent: ColumnLayout {
				spacing: Appearance.spacing.large

				MaterialIcon {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3outlineVariant
					font.pointSize: Appearance.font.size.extraLarge * 2
					text: "desktop_windows"
				}

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3outlineVariant
					font.family: Appearance.font.family.mono
					font.pointSize: Appearance.font.size.large
					font.weight: 500
					text: qsTr("No Sessions Found")
				}
			}
		}

		ListView {
			anchors.fill: parent
			clip: true
			currentIndex: root.greeter.sessionIndex
			model: root.greeter.sessions
			spacing: Appearance.spacing.small

			delegate: CustomRect {
				required property int index
				required property var modelData

				anchors.left: parent?.left
				anchors.right: parent?.right
				color: ListView.isCurrentItem ? DynamicColors.palette.m3secondaryContainer : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
				implicitHeight: row.implicitHeight + Appearance.padding.normal * 2
				radius: Appearance.rounding.normal

				StateLayer {
					function onClicked(): void {
						root.greeter.sessionIndex = index;
					}

					color: ListView.isCurrentItem ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
				}

				RowLayout {
					id: row

					anchors.fill: parent
					anchors.margins: Appearance.padding.normal
					spacing: Appearance.spacing.normal

					MaterialIcon {
						color: ListView.isCurrentItem ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurfaceVariant
						text: modelData.kind === "x11" ? "tv" : "desktop_windows"
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: Appearance.spacing.small / 2

						CustomText {
							Layout.fillWidth: true
							color: ListView.isCurrentItem ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
							elide: Text.ElideRight
							font.pointSize: Appearance.font.size.normal
							font.weight: 600
							text: modelData.name
						}

						CustomText {
							Layout.fillWidth: true
							color: DynamicColors.palette.m3outline
							elide: Text.ElideRight
							font.family: Appearance.font.family.mono
							font.pointSize: Appearance.font.size.small
							text: modelData.kind
						}
					}

					MaterialIcon {
						color: DynamicColors.palette.m3primary
						opacity: ListView.isCurrentItem ? 1 : 0
						text: "check_circle"
					}
				}
			}
		}
	}
}
