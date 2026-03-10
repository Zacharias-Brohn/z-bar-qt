pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

Item {
	id: root

	required property Canvas drawing
	property bool expanded: true
	required property ShellScreen screen
	readonly property bool shouldBeActive: visibilities.isDrawing
	required property var visibilities

	implicitHeight: content.implicitHeight
	implicitWidth: 0
	visible: width > 0

	states: [
		State {
			name: "hidden"
			when: !root.shouldBeActive

			PropertyChanges {
				root.implicitWidth: 0
			}

			PropertyChanges {
				icon.opacity: 0
			}

			PropertyChanges {
				content.opacity: 0
			}
		},
		State {
			name: "collapsed"
			when: root.shouldBeActive && !root.expanded

			PropertyChanges {
				root.implicitWidth: icon.implicitWidth
			}

			PropertyChanges {
				icon.opacity: 1
			}

			PropertyChanges {
				content.opacity: 0
			}
		},
		State {
			name: "visible"
			when: root.shouldBeActive && root.expanded

			PropertyChanges {
				root.implicitWidth: content.implicitWidth
			}

			PropertyChanges {
				icon.opacity: 0
			}

			PropertyChanges {
				content.opacity: 1
			}
		}
	]
	transitions: [
		Transition {
			from: "*"
			to: "*"

			ParallelAnimation {
				Anim {
					easing.bezierCurve: MaterialEasing.expressiveEffects
					property: "implicitWidth"
					target: root
				}

				Anim {
					duration: Appearance.anim.durations.small
					property: "opacity"
					target: icon
				}

				Anim {
					duration: Appearance.anim.durations.small
					property: "opacity"
					target: content
				}
			}
		}
	]

	onVisibleChanged: {
		if (!visible)
			root.expanded = true;
	}

	Loader {
		id: icon

		active: Qt.binding(() => root.shouldBeActive || root.visible)
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		height: content.contentItem.height
		opacity: 1

		sourceComponent: MaterialIcon {
			font.pointSize: Appearance.font.size.larger
			text: "arrow_forward_ios"
		}
	}

	Loader {
		id: content

		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		sourceComponent: Content {
			drawing: root.drawing
			visibilities: root.visibilities
		}

		Component.onCompleted: active = Qt.binding(() => root.shouldBeActive || root.visible)
	}
}
