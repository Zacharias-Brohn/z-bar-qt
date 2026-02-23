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

	ListModel {
		id: listModel
		ListElement {
			name: "General"
			icon: "settings"
		}
		
		ListElement {
			name: "Wallpaper"
			icon: "wallpaper"
		}

		ListElement {
			name: "Bar"
			icon: "settop_component"
		}

		ListElement {
			name: "Lockscreen"
			icon: "lock"
		}
		
		ListElement {
			name: "Services"
			icon: "build_circle"
		}

		ListElement {
			name: "Notifications"
			icon: "notifications"
		}

		ListElement {
			name: "Sidebar"
			icon: "view_sidebar"
		}

		ListElement {
			name: "Utilities"
			icon: "handyman"
		}

		ListElement {
			name: "Dashboard"
			icon: "dashboard"
		}

		ListElement {
			name: "Appearance"
			icon: "colors"
		}

		ListElement {
			name: "On screen display"
			icon: "display_settings"
		}

		ListElement {
			name: "Launcher"
			icon: "rocket_launch"
		}

		ListElement {
			name: "Colors"
			icon: "colors"
		}
	}

	required property Item content

	implicitWidth: clayout.contentWidth + Appearance.padding.smaller * 2
	implicitHeight: clayout.contentHeight + Appearance.padding.smaller * 2

	CustomRect {

		anchors.fill: parent

		color: DynamicColors.tPalette.m3surfaceContainer
		radius: 4

		CustomListView {
			id: clayout
			anchors.centerIn: parent
			model: listModel

			contentWidth: contentItem.childrenRect.width
			contentHeight: contentItem.childrenRect.height
			implicitWidth: contentItem.childrenRect.width
			implicitHeight: contentItem.childrenRect.height

			spacing: 5

			highlight: CustomRect {
				color: DynamicColors.palette.m3primary
				radius: 4

				y: clayout.currentItem?.y ?? 0
				implicitWidth: clayout.width
				implicitHeight: clayout.currentItem?.implicitHeight ?? 0

				Behavior on y {
					Anim {
						duration: Appearance.anim.durations.small
						easing.bezierCurve: Appearance.anim.curves.expressiveEffects
					}
				}
			}

			highlightFollowsCurrentItem: false

			delegate: Category {}
		}
	}

	component Category: CustomRect {
		id: categoryItem

		required property string name
		required property string icon
		required property int index

		implicitWidth: 200
		implicitHeight: 42
		radius: 4

		RowLayout {
			id: layout

			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.margins: Appearance.padding.smaller
			
			MaterialIcon {
				id: icon

				text: categoryItem.icon
				color: categoryItem.index === clayout.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				font.pointSize: 22
				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.preferredWidth: icon.contentWidth
				Layout.fillHeight: true
				verticalAlignment: Text.AlignVCenter
			}

			CustomText {
				id: text

				text: categoryItem.name
				color: categoryItem.index === clayout.currentIndex ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: Appearance.spacing.normal
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
