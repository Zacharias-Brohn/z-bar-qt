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
			id: sessions

			anchors.fill: parent
			clip: true
			currentIndex: root.greeter.sessionIndex
			highlightFollowsCurrentItem: false
			model: root.greeter.sessions
			spacing: Appearance.spacing.small

			delegate: CustomRect {
				id: session

				required property int index
				required property var modelData

				anchors.left: parent?.left
				anchors.right: parent?.right
				implicitHeight: row.implicitHeight + Appearance.padding.normal * 2
				radius: Appearance.rounding.normal - Appearance.padding.smaller

				StateLayer {
					function onClicked(): void {
						root.greeter.sessionIndex = index;
					}
				}

				RowLayout {
					id: row

					anchors.fill: parent
					anchors.margins: Appearance.padding.normal
					spacing: Appearance.spacing.normal

					MaterialIcon {
						color: session.index === sessions.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurfaceVariant
						font.pointSize: Appearance.font.size.extraLarge
						text: modelData.kind === "x11" ? "tv" : "desktop_windows"
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: Appearance.spacing.small / 2

						CustomText {
							Layout.fillWidth: true
							color: session.index === sessions.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
							elide: Text.ElideRight
							font.pointSize: Appearance.font.size.normal
							font.weight: 600
							text: modelData.name
						}

						CustomText {
							Layout.fillWidth: true
							color: session.index === sessions.currentIndex ? DynamicColors.palette.m3onPrimaryFixedVariant : DynamicColors.palette.m3onSurfaceVariant
							elide: Text.ElideRight
							font.family: Appearance.font.family.mono
							font.pointSize: Appearance.font.size.small
							text: modelData.kind
						}
					}
				}
			}
			highlight: CustomRect {
				color: DynamicColors.palette.m3primary
				implicitHeight: sessions.currentItem?.implicitHeight ?? 0
				implicitWidth: sessions.width
				radius: Appearance.rounding.normal - Appearance.padding.smaller
				y: sessions.currentItem?.y ?? 0

				Behavior on y {
					Anim {
						duration: Appearance.anim.durations.small
						easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					}
				}
			}
		}
	}
}
