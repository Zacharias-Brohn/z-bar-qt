import QtQuick
import qs.Components
import qs.Config

Item {
	id: root

	required property Item panels
	required property var visibilities

	implicitHeight: content.implicitHeight
	implicitWidth: Math.max(panels.sidebar.width, content.implicitWidth)
	visible: height > 0

	states: State {
		name: "hidden"
		when: root.visibilities.sidebar

		PropertyChanges {
			root.implicitHeight: 0
		}
	}
	transitions: Transition {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
			property: "implicitHeight"
			target: root
		}
	}

	Content {
		id: content

		panels: root.panels
		visibilities: root.visibilities
	}
}
