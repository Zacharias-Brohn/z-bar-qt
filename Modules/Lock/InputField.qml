pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	property string buffer
	required property Pam pam
	readonly property alias placeholder: placeholder

	Layout.fillHeight: true
	Layout.fillWidth: true
	clip: true

	Connections {
		function onBufferChanged(): void {
			if (root.pam.buffer.length > root.buffer.length) {
				charList.bindImWidth();
			} else if (root.pam.buffer.length === 0) {
				charList.implicitWidth = charList.implicitWidth;
				placeholder.animate = true;
			}

			root.buffer = root.pam.buffer;
		}

		target: root.pam
	}

	CustomText {
		id: placeholder

		anchors.centerIn: parent
		animate: true
		color: root.pam.passwd.active ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3outline
		font.family: Appearance.font.family.mono
		font.pointSize: Appearance.font.size.normal
		opacity: root.buffer ? 0 : 1
		text: {
			if (root.pam.passwd.active)
				return qsTr("Loading...");
			if (root.pam.state === "max")
				return qsTr("You have reached the maximum number of tries");
			return qsTr("Enter your password");
		}

		Behavior on opacity {
			Anim {
			}
		}
	}

	ListView {
		id: charList

		readonly property int fullWidth: count * (implicitHeight + spacing) - spacing

		function bindImWidth(): void {
			imWidthBehavior.enabled = false;
			implicitWidth = Qt.binding(() => fullWidth);
			imWidthBehavior.enabled = true;
		}

		anchors.centerIn: parent
		anchors.horizontalCenterOffset: implicitWidth > root.width ? -(implicitWidth - root.width) / 2 : 0
		implicitHeight: Appearance.font.size.normal
		implicitWidth: fullWidth
		interactive: false
		orientation: Qt.Horizontal
		spacing: Appearance.spacing.small / 2

		delegate: CustomRect {
			id: ch

			color: DynamicColors.palette.m3onSurface
			implicitHeight: charList.implicitHeight
			implicitWidth: implicitHeight
			opacity: 0
			radius: Appearance.rounding.small / 2
			scale: 0

			Behavior on opacity {
				Anim {
				}
			}
			Behavior on scale {
				Anim {
					duration: Appearance.anim.durations.expressiveFastSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
				}
			}

			Component.onCompleted: {
				opacity = 1;
				scale = 1;
			}
			ListView.onRemove: removeAnim.start()

			SequentialAnimation {
				id: removeAnim

				PropertyAction {
					property: "ListView.delayRemove"
					target: ch
					value: true
				}

				ParallelAnimation {
					Anim {
						property: "opacity"
						target: ch
						to: 0
					}

					Anim {
						property: "scale"
						target: ch
						to: 0.5
					}
				}

				PropertyAction {
					property: "ListView.delayRemove"
					target: ch
					value: false
				}
			}
		}
		Behavior on implicitWidth {
			id: imWidthBehavior

			Anim {
			}
		}
		model: ScriptModel {
			values: root.buffer.split("")
		}
	}
}
