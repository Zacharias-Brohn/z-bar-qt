pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Paths
import qs.Components
import qs.Helpers
import qs.Config

ColumnLayout {
	id: root

	readonly property real centerScale: Math.min(1, screenHeight / 1440)
	readonly property int centerWidth: Config.lock.sizes.centerWidth * centerScale
	required property var greeter
	required property real screenHeight

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

	CustomText {
		Layout.alignment: Qt.AlignHCenter
		color: DynamicColors.palette.m3onSurfaceVariant
		font.family: Appearance.font.family.mono
		font.pointSize: Appearance.font.size.normal
		font.weight: 600
		text: root.greeter.username
		visible: text.length > 0
	}

	CustomRect {
		Layout.alignment: Qt.AlignHCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		focus: true
		implicitHeight: input.implicitHeight + Appearance.padding.small * 2
		implicitWidth: root.centerWidth * 0.8
		radius: Appearance.rounding.full

		Keys.onPressed: event => {
			if (root.greeter.launching)
				return;

			if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
				inputField.placeholder.animate = false;

			root.greeter.handleKey(event);
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
				implicitHeight: statusIcon.implicitHeight + Appearance.padding.small * 2
				implicitWidth: implicitHeight

				MaterialIcon {
					id: statusIcon

					anchors.centerIn: parent
					animate: true
					color: root.greeter.errorMessage ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurface
					opacity: root.greeter.launching ? 0 : 1
					text: {
						if (root.greeter.errorMessage)
							return "error";
						if (root.greeter.awaitingResponse)
							return root.greeter.echoResponse ? "person" : "lock";
						if (root.greeter.buffer.length > 0)
							return "password";
						return "login";
					}

					Behavior on opacity {
						Anim {
						}
					}
				}

				CircularIndicator {
					anchors.fill: parent
					running: root.greeter.launching
				}
			}

			InputField {
				id: inputField

				greeter: root.greeter
			}

			CustomRect {
				color: root.greeter.buffer && !root.greeter.launching ? DynamicColors.palette.m3primary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
				implicitHeight: enterIcon.implicitHeight + Appearance.padding.small * 2
				implicitWidth: implicitHeight
				radius: Appearance.rounding.full

				StateLayer {
					function onClicked(): void {
						root.greeter.submit();
					}

					color: root.greeter.buffer && !root.greeter.launching ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
				}

				MaterialIcon {
					id: enterIcon

					anchors.centerIn: parent
					color: root.greeter.buffer && !root.greeter.launching ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSurface
					font.weight: 500
					text: root.greeter.launching ? "hourglass_top" : "arrow_forward"
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

			readonly property bool isError: !!root.greeter.errorMessage
			readonly property string msg: {
				if (root.greeter.errorMessage)
					return root.greeter.errorMessage;

				if (root.greeter.launching) {
					if (root.greeter.selectedSession && root.greeter.selectedSession.name)
						return qsTr("Starting %1...").arg(root.greeter.selectedSession.name);
					return qsTr("Starting session...");
				}

				if (root.greeter.awaitingResponse && root.greeter.promptMessage)
					return root.greeter.promptMessage;

				return "";
			}

			anchors.left: parent.left
			anchors.right: parent.right
			color: isError ? DynamicColors.palette.m3error : DynamicColors.palette.m3primary
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

				target: root.greeter
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
