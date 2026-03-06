pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import QtQuick

Item {
	id: root

	required property var panels
	readonly property Props props: Props {
	}
	required property var visibilities

	implicitWidth: 0
	visible: width > 0

	states: State {
		name: "visible"
		when: root.visibilities.sidebar

		PropertyChanges {
			root.implicitWidth: Config.sidebar.sizes.width
		}
	}
	transitions: [
		Transition {
			from: ""
			to: "visible"

			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitWidth"
				target: root
			}
		},
		Transition {
			from: "visible"
			to: ""

			Anim {
				easing.bezierCurve: MaterialEasing.expressiveEffects
				property: "implicitWidth"
				target: root
			}
		}
	]

	Loader {
		id: content

		active: true
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 0
		anchors.left: parent.left
		anchors.margins: 8
		anchors.top: parent.top

		sourceComponent: Content {
			implicitWidth: Config.sidebar.sizes.width - 8 * 2
			props: root.props
			visibilities: root.visibilities
		}

		Component.onCompleted: active = Qt.binding(() => (root.visibilities.sidebar && Config.sidebar.enabled) || root.visible)
	}
}
