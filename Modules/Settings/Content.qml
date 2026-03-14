import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import qs.Components
import qs.Modules as Modules
import qs.Modules.Settings.Categories as Cat
import qs.Config
import qs.Helpers

Item {
	id: root

	property string currentCategory: "general"
	readonly property real nonAnimHeight: Math.floor(screen.height / 1.5) + viewWrapper.anchors.margins * 2
	readonly property real nonAnimWidth: view.implicitWidth + Math.floor(screen.width / 2) + viewWrapper.anchors.margins * 2
	required property ShellScreen screen
	required property PersistentProperties visibilities

	implicitHeight: nonAnimHeight
	implicitWidth: nonAnimWidth

	Connections {
		function onCurrentCategoryChanged() {
			stack.pop();
			if (currentCategory === "general")
				stack.push(general);
			else if (currentCategory === "wallpaper")
				stack.push(background);
			else if (currentCategory === "appearance")
				stack.push(appearance);
			else if (currentCategory === "lockscreen")
				stack.push(lockscreen);
		}

		target: root
	}

	CustomClippingRect {
		id: viewWrapper

		anchors.fill: parent
		anchors.margins: Appearance.padding.smaller
		radius: Appearance.rounding.large - Appearance.padding.smaller

		Item {
			id: view

			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.top: parent.top
			implicitWidth: layout.implicitWidth

			Categories {
				id: layout

				anchors.fill: parent
				content: root
			}
		}

		CustomClippingRect {
			id: categoryContent

			anchors.bottom: parent.bottom
			anchors.left: view.right
			anchors.leftMargin: Appearance.spacing.smaller
			anchors.right: parent.right
			anchors.top: parent.top
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: Appearance.rounding.normal

			StackView {
				id: stack

				anchors.fill: parent
				anchors.margins: Appearance.padding.smaller
				initialItem: general
			}
		}
	}

	Component {
		id: general

		Cat.General {
		}
	}

	Component {
		id: background

		Cat.Background {
		}
	}

	Component {
		id: appearance

		Cat.Appearance {
		}
	}

	Component {
		id: lockscreen

		Cat.Lockscreen {
		}
	}
}
