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
			name: "General"
		}

		ListElement {
			icon: "wallpaper"
			name: "Wallpaper"
		}

		ListElement {
			icon: "settop_component"
			name: "Bar"
		}

		ListElement {
			icon: "lock"
			name: "Lockscreen"
		}

		ListElement {
			icon: "build_circle"
			name: "Services"
		}

		ListElement {
			icon: "notifications"
			name: "Notifications"
		}

		ListElement {
			icon: "view_sidebar"
			name: "Sidebar"
		}

		ListElement {
			icon: "handyman"
			name: "Utilities"
		}

		ListElement {
			icon: "dashboard"
			name: "Dashboard"
		}

		ListElement {
			icon: "colors"
			name: "Appearance"
		}

		ListElement {
			icon: "display_settings"
			name: "On screen display"
		}

		ListElement {
			icon: "rocket_launch"
			name: "Launcher"
		}

		ListElement {
			icon: "colors"
			name: "Colors"
		}
	}

	CustomRect {
		anchors.fill: parent
		color: DynamicColors.tPalette.m3surfaceContainer
		radius: 4

		CustomListView {
			id: clayout

			anchors.centerIn: parent
			contentHeight: contentItem.childrenRect.height
			contentWidth: contentItem.childrenRect.width
			highlightFollowsCurrentItem: false
			implicitHeight: contentItem.childrenRect.height
			implicitWidth: contentItem.childrenRect.width
			model: listModel
			spacing: 5

			delegate: Category {
			}
			highlight: CustomRect {
				color: DynamicColors.palette.m3primary
				implicitHeight: clayout.currentItem?.implicitHeight ?? 0
				implicitWidth: clayout.width
				radius: 4
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
		required property string name

		implicitHeight: 42
		implicitWidth: 200
		radius: 4

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
				font.pointSize: 22
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
				root.content.currentCategory = categoryItem.name.toLowerCase();
				clayout.currentIndex = categoryItem.index;
			}
		}
	}
}
