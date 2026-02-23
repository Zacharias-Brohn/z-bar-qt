import Quickshell
import QtQuick
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	required property PersistentProperties visibilities
	required property var panels

	implicitWidth: content.implicitWidth
	implicitHeight: 0

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
				target: root
				property: "implicitHeight"
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		},

		Transition {
			from: "visible"
			to: ""

			Anim {
				target: root
				property: "implicitHeight"
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}
	]

	Loader {
		id: content
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom

		visible: true
		active: true

		sourceComponent: Content {
			visibilities: root.visibilities
		}
	}
}
