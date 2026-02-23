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

	required property PersistentProperties visibilities
	readonly property real nonAnimWidth: view.implicitWidth + 500 + viewWrapper.anchors.margins * 2 
	readonly property real nonAnimHeight: view.implicitHeight + viewWrapper.anchors.margins * 2
	property string currentCategory: "general"

	implicitWidth: nonAnimWidth
	implicitHeight: nonAnimHeight

	Connections {
		target: root
		
		function onCurrentCategoryChanged() {
			stack.pop();
			if ( currentCategory === "general" ) {
				stack.push(general);
			} else if ( currentCategory === "wallpaper" ) {
				stack.push(background);
			} else if ( currentCategory === "appearance" ) {
				stack.push(appearance);
			}
		}
	}

	ClippingRectangle {
		id: viewWrapper
		anchors.fill: parent
		anchors.margins: Appearance.padding.smaller
		color: "transparent"

		Item {
			id: view
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			implicitWidth: layout.implicitWidth
			implicitHeight: layout.implicitHeight
			
			Categories {
				id: layout

				content: root
				
				anchors.fill: parent
			}
		}

		CustomClippingRect {
			id: categoryContent
			
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			anchors.left: view.right
			anchors.leftMargin: Appearance.spacing.smaller

			radius: 4

			color: DynamicColors.tPalette.m3surfaceContainer

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

		Cat.General {}
	}

	Component {
		id: background

		Cat.Background {}
	}

	Component {
		id: appearance

		Cat.Appearance {}
	}
}
