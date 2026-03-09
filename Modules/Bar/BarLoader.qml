pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Config
import qs.Helpers
import qs.Modules.UPower
import qs.Modules.Network

Item {
	id: root

	required property PanelWindow bar
	readonly property int contentHeight: Config.barConfig.height + padding * 2
	readonly property int exclusiveZone: Config.barConfig.autoHide ? Config.barConfig.border : contentHeight
	property bool isHovered
	readonly property int padding: Math.max(Appearance.padding.smaller, Config.barConfig.border)
	required property Wrapper popouts
	required property ShellScreen screen
	readonly property bool shouldBeVisible: (!Config.barConfig.autoHide || visibilities.bar)
	readonly property int vPadding: 6
	required property PersistentProperties visibilities

	function checkPopout(x: real): void {
		content.item?.checkPopout(x);
	}

	implicitHeight: Config.barConfig.border
	visible: width > Config.barConfig.border

	states: State {
		name: "visible"
		when: root.shouldBeVisible

		PropertyChanges {
			root.implicitHeight: root.contentHeight
		}
	}
	transitions: [
		Transition {
			from: ""
			to: "visible"

			Anim {
				duration: Appearance.anim.durations.expressiveDefaultSpatial
				easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
				property: "implicitHeight"
				target: root
			}
		},
		Transition {
			from: "visible"
			to: ""

			Anim {
				easing.bezierCurve: Appearance.anim.curves.emphasized
				property: "implicitHeight"
				target: root
			}
		}
	]

	Loader {
		id: content

		active: root.shouldBeVisible || root.visible
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top

		sourceComponent: Bar {
			height: root.contentHeight
			popouts: root.popouts
			screen: root.screen
			visibilities: root.visibilities
		}
	}
}
