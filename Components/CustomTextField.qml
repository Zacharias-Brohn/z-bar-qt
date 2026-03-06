pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.Config

TextField {
	id: root

	background: null
	color: DynamicColors.palette.m3onSurface
	cursorVisible: !readOnly
	font.family: Appearance.font.family.sans
	font.pointSize: Appearance.font.size.smaller
	placeholderTextColor: DynamicColors.palette.m3outline
	renderType: echoMode === TextField.Password ? TextField.QtRendering : TextField.NativeRendering

	Behavior on color {
		CAnim {
		}
	}
	cursorDelegate: CustomRect {
		id: cursor

		property bool disableBlink

		color: DynamicColors.palette.m3primary
		implicitWidth: 2
		radius: Appearance.rounding.normal

		Behavior on opacity {
			Anim {
				duration: Appearance.anim.durations.small
			}
		}

		Connections {
			function onCursorPositionChanged(): void {
				if (root.activeFocus && root.cursorVisible) {
					cursor.opacity = 1;
					cursor.disableBlink = true;
					enableBlink.restart();
				}
			}

			target: root
		}

		Timer {
			id: enableBlink

			interval: 100

			onTriggered: cursor.disableBlink = false
		}

		Timer {
			interval: 500
			repeat: true
			running: root.activeFocus && root.cursorVisible && !cursor.disableBlink
			triggeredOnStart: true

			onTriggered: parent.opacity = parent.opacity === 1 ? 0 : 1
		}

		Binding {
			cursor.opacity: 0
			when: !root.activeFocus || !root.cursorVisible
		}
	}
	Behavior on placeholderTextColor {
		CAnim {
		}
	}
}
