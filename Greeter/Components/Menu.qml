pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Config

Elevation {
	id: root

	property MenuItem active: items[0] ?? null
	property bool expanded
	property list<MenuItem> items

	signal itemSelected(item: MenuItem)

	implicitHeight: root.expanded ? column.implicitHeight + Appearance.padding.small * 2 : 0
	implicitWidth: Math.max(200, column.implicitWidth)
	level: 2
	opacity: root.expanded ? 1 : 0
	radius: Appearance.rounding.normal

	Behavior on implicitHeight {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}
	Behavior on opacity {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
		}
	}

	CustomClippingRect {
		anchors.fill: parent
		color: DynamicColors.palette.m3surfaceContainer
		radius: parent.radius

		ColumnLayout {
			id: column

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: 5

			Repeater {
				model: root.items

				CustomRect {
					id: item

					readonly property bool active: modelData === root.active
					required property int index
					required property MenuItem modelData

					Layout.fillWidth: true
					implicitHeight: menuOptionRow.implicitHeight + Appearance.padding.normal * 2
					implicitWidth: menuOptionRow.implicitWidth + Appearance.padding.normal * 2

					CustomRect {
						anchors.fill: parent
						anchors.leftMargin: Appearance.padding.small
						anchors.rightMargin: Appearance.padding.small
						color: Qt.alpha(DynamicColors.palette.m3secondaryContainer, active ? 1 : 0)
						radius: Appearance.rounding.normal - Appearance.padding.small

						StateLayer {
							function onClicked(): void {
								root.itemSelected(item.modelData);
								root.active = item.modelData;
								root.expanded = false;
							}

							color: item.active ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
							disabled: !root.expanded
						}
					}

					RowLayout {
						id: menuOptionRow

						anchors.fill: parent
						anchors.margins: Appearance.padding.normal
						spacing: Appearance.spacing.small

						MaterialIcon {
							Layout.alignment: Qt.AlignVCenter
							color: item.active ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurfaceVariant
							text: item.modelData.icon
						}

						CustomText {
							Layout.alignment: Qt.AlignVCenter
							Layout.fillWidth: true
							color: item.active ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
							text: item.modelData.text
						}

						Loader {
							Layout.alignment: Qt.AlignVCenter
							active: item.modelData.trailingIcon.length > 0
							visible: active

							sourceComponent: MaterialIcon {
								color: item.active ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
								text: item.modelData.trailingIcon
							}
						}
					}
				}
			}
		}
	}
}
