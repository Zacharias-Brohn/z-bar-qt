import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	required property var panels
	required property PersistentProperties visibilities

	implicitHeight: 0
	implicitWidth: content.implicitWidth
	visible: height > 0

	states: State {
		name: "visible"
		when: root.visibilities.settings

		PropertyChanges {
			root.implicitHeight: content.implicitHeight
		}
	}
	transitions: [
		Transition {
			from: ""
			to: "visible"

			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitHeight"
				target: root
			}
		},
		Transition {
			from: "visible"
			to: ""

			Anim {
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitHeight"
				target: root
			}
		}
	]

	Loader {
		id: content

		active: true
		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		visible: true

		sourceComponent: Content {
			visibilities: root.visibilities
		}
	}
}
