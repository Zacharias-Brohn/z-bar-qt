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

	implicitWidth: clayout.implicitWidth + Appearance.padding.smaller * 2
	implicitHeight: clayout.implicitHeight + Appearance.padding.smaller * 2

	CustomRect {

		anchors.fill: parent

		color: DynamicColors.tPalette.m3surfaceContainer
		radius: 4

		ColumnLayout {
			id: clayout

			spacing: 5

			anchors.centerIn: parent

			Category {
				name: "General"
				icon: "settings"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}
			
			Category {
				name: "Wallpaper"
				icon: "wallpaper"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Bar"
				icon: "settop_component"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Lockscreen"
				icon: "lock"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}
			
			Category {
				name: "Services"
				icon: "build_circle"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Notifications"
				icon: "notifications"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Sidebar"
				icon: "view_sidebar"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Utilities"
				icon: "handyman"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Dashboard"
				icon: "dashboard"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Appearance"
				icon: "colors"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "On screen display"
				icon: "display_settings"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Launcher"
				icon: "rocket_launch"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}

			Category {
				name: "Colors"
				icon: "colors"
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
			}
		}
	}

	component Category: CustomRect {
		id: categoryItem

		required property string name
		required property string icon

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
				font.pointSize: 22
				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.preferredWidth: icon.contentWidth
				Layout.fillHeight: true
				verticalAlignment: Text.AlignVCenter
			}

			CustomText {
				id: text

				text: categoryItem.name
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
			}
		}
	}
}
