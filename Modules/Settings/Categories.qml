pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Modules
import qs.Config
import qs.Helpers

Item {
	id: root

	required property Item content

	implicitHeight: clayout.contentHeight + Appearance.padding.smaller * 2
	implicitWidth: clayout.contentWidth + Appearance.padding.smaller * 2

	ListModel {
		id: listModel

		ListElement {
			icon: "settings"
			key: "general"
			name: "General"
		}

		ListElement {
			icon: "wallpaper"
			key: "wallpaper"
			name: "Wallpaper"
		}

		ListElement {
			icon: "settop_component"
			key: "bar"
			name: "Bar"
		}

		ListElement {
			icon: "lock"
			key: "lockscreen"
			name: "Lockscreen"
		}

		ListElement {
			icon: "build_circle"
			key: "services"
			name: "Services"
		}

		ListElement {
			icon: "notifications"
			key: "notifications"
			name: "Notifications"
		}

		ListElement {
			icon: "view_sidebar"
			key: "sidebar"
			name: "Sidebar"
		}

		ListElement {
			icon: "handyman"
			key: "utilities"
			name: "Utilities"
		}

		ListElement {
			icon: "dashboard"
			key: "dashboard"
			name: "Dashboard"
		}

		ListElement {
			icon: "colors"
			key: "appearance"
			name: "Appearance"
		}

		ListElement {
			icon: "display_settings"
			key: "osd"
			name: "On screen display"
		}

		ListElement {
			icon: "rocket_launch"
			key: "launcher"
			name: "Launcher"
		}
	}

	CustomClippingRect {
		anchors.fill: parent
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: Appearance.rounding.normal

		CustomListView {
			id: clayout

			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.margins: Appearance.padding.smaller
			anchors.top: parent.top
			boundsBehavior: Flickable.StopAtBounds
			contentWidth: contentItem.childrenRect.width
			highlightFollowsCurrentItem: false
			implicitWidth: contentItem.childrenRect.width
			model: listModel
			spacing: 5

			delegate: Category {
			}
			highlight: CustomRect {
				color: DynamicColors.palette.m3primary
				implicitHeight: clayout.currentItem?.implicitHeight ?? 0
				implicitWidth: clayout.width
				radius: Appearance.rounding.normal - Appearance.padding.smaller
				y: clayout.currentItem?.y ?? 0

				Behavior on y {
					Anim {
						duration: Appearance.anim.durations.small
						easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					}
				}
			}
		}
	}

	component Category: CustomRect {
		id: categoryItem

		required property string icon
		required property int index
		required property string key
		required property string name

		implicitHeight: 42
		implicitWidth: 200
		radius: Appearance.rounding.normal - Appearance.padding.smaller

		RowLayout {
			id: layout

			anchors.left: parent.left
			anchors.margins: Appearance.padding.smaller
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter

			MaterialIcon {
				id: icon

				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillHeight: true
				Layout.preferredWidth: icon.contentWidth
				color: categoryItem.index === clayout.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				font.pointSize: Appearance.font.size.small * 2
				text: categoryItem.icon
				verticalAlignment: Text.AlignVCenter
			}

			CustomText {
				id: text

				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.leftMargin: Appearance.spacing.normal
				color: categoryItem.index === clayout.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				text: categoryItem.name
				verticalAlignment: Text.AlignVCenter
			}
		}

		StateLayer {
			id: layer

			onClicked: {
				root.content.currentCategory = categoryItem.key;
				clayout.currentIndex = categoryItem.index;
			}
		}
	}
}
