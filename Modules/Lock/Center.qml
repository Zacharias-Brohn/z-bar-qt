pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Paths
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules

ColumnLayout {
	id: root

	readonly property real centerScale: Math.min(1, (lock.screen?.height ?? 1440) / 1440)
	readonly property int centerWidth: Config.lock.sizes.centerWidth * centerScale
	required property var lock

	Layout.fillHeight: true
	Layout.fillWidth: false
	Layout.preferredWidth: centerWidth
	spacing: Appearance.spacing.large * 2

	RowLayout {
		Layout.alignment: Qt.AlignHCenter
		spacing: Appearance.spacing.small

		CustomText {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3secondary
			font.bold: true
			font.family: Appearance.font.family.clock
			font.pointSize: Math.floor(Appearance.font.size.extraLarge * 3 * root.centerScale)
			text: Time.hourStr
		}

		CustomText {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3primary
			font.bold: true
			font.family: Appearance.font.family.clock
			font.pointSize: Math.floor(Appearance.font.size.extraLarge * 3 * root.centerScale)
			text: ":"
		}

		CustomText {
			Layout.alignment: Qt.AlignVCenter
			color: DynamicColors.palette.m3secondary
			font.bold: true
			font.family: Appearance.font.family.clock
			font.pointSize: Math.floor(Appearance.font.size.extraLarge * 3 * root.centerScale)
			text: Time.minuteStr
		}
	}

	CustomText {
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: -Appearance.padding.large * 2
		color: DynamicColors.palette.m3tertiary
		font.bold: true
		font.family: Appearance.font.family.mono
		font.pointSize: Math.floor(Appearance.font.size.extraLarge * root.centerScale)
		text: Time.format("dddd, d MMMM yyyy")
	}

	CustomClippingRect {
		Layout.alignment: Qt.AlignHCenter
		Layout.topMargin: Appearance.spacing.large * 2
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: root.centerWidth / 2
		implicitWidth: root.centerWidth / 2
		radius: Appearance.rounding.full

		MaterialIcon {
			anchors.centerIn: parent
			color: DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: Math.floor(root.centerWidth / 4)
			text: "person"
		}

		CachingImage {
			id: pfp

			anchors.fill: parent
			path: `${Paths.home}/.face`
		}
	}

	CustomRect {
		Layout.alignment: Qt.AlignHCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		focus: true
		implicitHeight: input.implicitHeight + Appearance.padding.small * 2
		implicitWidth: root.centerWidth * 0.8
		radius: Appearance.rounding.full

		Keys.onPressed: event => {
			if (root.lock.unlocking)
				return;

			if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
				inputField.placeholder.animate = false;

			root.lock.pam.handleKey(event);
		}
		onActiveFocusChanged: {
			if (!activeFocus)
				forceActiveFocus();
		}

		StateLayer {
			function onClicked(): void {
				parent.forceActiveFocus();
			}

			cursorShape: Qt.IBeamCursor
			hoverEnabled: false
		}

		RowLayout {
			id: input

			anchors.fill: parent
			anchors.margins: Appearance.padding.small
			spacing: Appearance.spacing.normal

			Item {
				implicitHeight: fprintIcon.implicitHeight + Appearance.padding.small * 2
				implicitWidth: implicitHeight

				MaterialIcon {
					id: fprintIcon

					anchors.centerIn: parent
					animate: true
					color: root.lock.pam.fprint.tries >= Config.lock.maxFprintTries ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurface
					opacity: root.lock.pam.passwd.active ? 0 : 1
					text: {
						if (root.lock.pam.fprint.tries >= Config.lock.maxFprintTries)
							return "fingerprint_off";
						if (root.lock.pam.fprint.active)
							return "fingerprint";
						return "lock";
					}

					Behavior on opacity {
						Anim {
						}
					}
				}

				CircularIndicator {
					anchors.fill: parent
					running: root.lock.pam.passwd.active
				}
			}

			InputField {
				id: inputField

				pam: root.lock.pam
			}

			CustomRect {
				color: root.lock.pam.buffer ? DynamicColors.palette.m3primary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
				implicitHeight: enterIcon.implicitHeight + Appearance.padding.small * 2
				implicitWidth: implicitHeight
				radius: Appearance.rounding.full

				StateLayer {
					function onClicked(): void {
						root.lock.pam.passwd.start();
					}

					color: root.lock.pam.buffer ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				}

				MaterialIcon {
					id: enterIcon

					anchors.centerIn: parent
					color: root.lock.pam.buffer ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
					font.weight: 500
					text: "arrow_forward"
				}
			}
		}
	}

	Item {
		Layout.fillWidth: true
		Layout.topMargin: -Appearance.spacing.large
		implicitHeight: Math.max(message.implicitHeight, stateMessage.implicitHeight)

		Behavior on implicitHeight {
			Anim {
			}
		}

		CustomText {
			id: stateMessage

			readonly property string msg: {
				if (Hypr.kbLayout !== Hypr.defaultKbLayout) {
					if (Hypr.capsLock && Hypr.numLock)
						return qsTr("Caps lock and Num lock are ON.\nKeyboard layout: %1").arg(Hypr.kbLayoutFull);
					if (Hypr.capsLock)
						return qsTr("Caps lock is ON. Kb layout: %1").arg(Hypr.kbLayoutFull);
					if (Hypr.numLock)
						return qsTr("Num lock is ON. Kb layout: %1").arg(Hypr.kbLayoutFull);
					return qsTr("Keyboard layout: %1").arg(Hypr.kbLayoutFull);
				}

				if (Hypr.capsLock && Hypr.numLock)
					return qsTr("Caps lock and Num lock are ON.");
				if (Hypr.capsLock)
					return qsTr("Caps lock is ON.");
				if (Hypr.numLock)
					return qsTr("Num lock is ON.");

				return "";
			}
			property bool shouldBeVisible

			anchors.left: parent.left
			anchors.right: parent.right
			animateProp: "opacity"
			color: DynamicColors.palette.m3onSurfaceVariant
			font.family: Appearance.font.family.mono
			horizontalAlignment: Qt.AlignHCenter
			lineHeight: 1.2
			opacity: shouldBeVisible && !message.msg ? 1 : 0
			scale: shouldBeVisible && !message.msg ? 1 : 0.7
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere

			Behavior on opacity {
				Anim {
				}
			}
			Behavior on scale {
				Anim {
				}
			}

			onMsgChanged: {
				if (msg) {
					if (opacity > 0) {
						animate = true;
						text = msg;
						animate = false;
					} else {
						text = msg;
					}
					shouldBeVisible = true;
				} else {
					shouldBeVisible = false;
				}
			}
		}

		CustomText {
			id: message

			readonly property string msg: {
				if (pam.fprintState === "error")
					return qsTr("FP ERROR: %1").arg(pam.fprint.message);
				if (pam.state === "error")
					return qsTr("PW ERROR: %1").arg(pam.passwd.message);

				if (pam.lockMessage)
					return pam.lockMessage;

				if (pam.state === "max" && pam.fprintState === "max")
					return qsTr("Maximum password and fingerprint attempts reached.");
				if (pam.state === "max") {
					if (pam.fprint.available)
						return qsTr("Maximum password attempts reached. Please use fingerprint.");
					return qsTr("Maximum password attempts reached.");
				}
				if (pam.fprintState === "max")
					return qsTr("Maximum fingerprint attempts reached. Please use password.");

				if (pam.state === "fail") {
					if (pam.fprint.available)
						return qsTr("Incorrect password. Please try again or use fingerprint.");
					return qsTr("Incorrect password. Please try again.");
				}
				if (pam.fprintState === "fail")
					return qsTr("Fingerprint not recognized (%1/%2). Please try again or use password.").arg(pam.fprint.tries).arg(Config.lock.maxFprintTries);

				return "";
			}
			readonly property Pam pam: root.lock.pam

			anchors.left: parent.left
			anchors.right: parent.right
			color: DynamicColors.palette.m3error
			font.family: Appearance.font.family.mono
			font.pointSize: Appearance.font.size.small
			horizontalAlignment: Qt.AlignHCenter
			opacity: 0
			scale: 0.7
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere

			onMsgChanged: {
				if (msg) {
					if (opacity > 0) {
						animate = true;
						text = msg;
						animate = false;

						exitAnim.stop();
						if (scale < 1)
							appearAnim.restart();
						else
							flashAnim.restart();
					} else {
						text = msg;
						exitAnim.stop();
						appearAnim.restart();
					}
				} else {
					appearAnim.stop();
					flashAnim.stop();
					exitAnim.start();
				}
			}

			Connections {
				function onFlashMsg(): void {
					exitAnim.stop();
					if (message.scale < 1)
						appearAnim.restart();
					else
						flashAnim.restart();
				}

				target: root.lock.pam
			}

			Anim {
				id: appearAnim

				properties: "scale,opacity"
				target: message
				to: 1

				onFinished: flashAnim.restart()
			}

			SequentialAnimation {
				id: flashAnim

				loops: 2

				FlashAnim {
					to: 0.3
				}

				FlashAnim {
					to: 1
				}
			}

			ParallelAnimation {
				id: exitAnim

				Anim {
					duration: Appearance.anim.durations.large
					property: "scale"
					target: message
					to: 0.7
				}

				Anim {
					duration: Appearance.anim.durations.large
					property: "opacity"
					target: message
					to: 0
				}
			}
		}
	}

	component FlashAnim: NumberAnimation {
		duration: Appearance.anim.durations.small
		easing.type: Easing.Linear
		property: "opacity"
		target: message
	}
}
