pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.Config
import qs.Helpers
import qs.Effects
import qs.Components
import qs.Modules

WlSessionLockSurface {
	id: root

	required property WlSessionLock lock
	required property Pam pam

	color: "transparent"

	TextInput {
		id: hiddenInput
		focus: true
		visible: false

		Keys.onPressed: function(event: KeyEvent): void {
			root.pam.handleKey(event);
			event.accepted = true;
		}

		onTextChanged: text = ""
	}

	ScreencopyView {
		id: background

		anchors.fill: parent
		captureSource: root.screen
		opacity: 1

		layer.enabled: true
		layer.effect: MultiEffect {
			autoPaddingEnabled: false
			blurEnabled: true
			blur: 2
			blurMax: 32
			blurMultiplier: 0
		}
	}

	// Image {
	// 	id: backgroundImage
	// 	anchors.fill: parent
	// 	asynchronous: true
	// 	source: WallpaperPath.lockscreenBg
	// }

	Rectangle {
		anchors.fill: parent
		color: "transparent"

		Rectangle {
			id: contentBox
			anchors.centerIn: parent

			// Material Design 3: Use surfaceContainer for elevated surfaces
			color: DynamicColors.tPalette.m3surfaceContainer
			radius: 28

			// M3 spacing: 24px horizontal, 32px vertical padding
			implicitWidth: Math.floor(childrenRect.width + 48)
			implicitHeight: Math.floor(childrenRect.height + 64)

			// M3 Elevation 2 shadow effect
			layer.enabled: true
			layer.effect: MultiEffect {
				source: contentBox
				blurEnabled: false
				blurMax: 12
				shadowBlur: 1
				shadowColor: DynamicColors.palette.m3shadow
				shadowOpacity: 0.3
				shadowEnabled: true
				autoPaddingEnabled: true
			}

			ColumnLayout {
				id: mainLayout
				anchors.centerIn: parent
				width: childrenRect.width
				spacing: 0

				// Title: M3 Display Small (32sp, 400 weight)
				Text {
					id: titleText
					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: 8

					text: "Session Locked"
					font.pixelSize: 32
					font.weight: Font.Normal
					font.letterSpacing: 0.5
					color: DynamicColors.palette.m3onSurface
				}

				// Support text: M3 Body Medium (14sp, 500 weight)
				Text {
					id: supportText
					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: 24

					text: "Please enter your password to unlock"
					font.pixelSize: 14
					font.weight: Font.Medium
					color: DynamicColors.palette.m3onSurfaceVariant
				}

				// Input field container
				Rectangle {
					id: inputContainer
					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: 16

					Layout.preferredWidth: 320
					Layout.preferredHeight: 48

					color: DynamicColors.tPalette.m3surfaceContainerHigh
					radius: 1000

					border.width: 1
					border.color: {
						if (root.pam.state === "error" || root.pam.state === "fail") {
							return DynamicColors.palette.m3error;
						}
						return DynamicColors.palette.m3outline;
					}

					Behavior on border.color {
						ColorAnimation { duration: 150 }
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

						implicitWidth: fullWidth
						implicitHeight: 16

						orientation: Qt.Horizontal
						spacing: 8
						interactive: false

						model: ScriptModel {
							values: root.pam.buffer.split("")
						}

						delegate: CustomRect {
							id: ch

							implicitWidth: implicitHeight
							implicitHeight: charList.implicitHeight

							color: DynamicColors.palette.m3onSurface
							radius: 1000

							opacity: 0
							scale: 0
							Component.onCompleted: {
								opacity = 1;
								scale = 1;
							}
							ListView.onRemove: removeAnim.start()

							SequentialAnimation {
								id: removeAnim

								PropertyAction {
									target: ch
									property: "ListView.delayRemove"
									value: true
								}
								ParallelAnimation {
									Anim {
										target: ch
										property: "opacity"
										to: 0
									}
									Anim {
										target: ch
										property: "scale"
										to: 0.5
									}
								}
								PropertyAction {
									target: ch
									property: "ListView.delayRemove"
									value: false
								}
							}

							Behavior on opacity {
								Anim {}
							}

							Behavior on scale {
								Anim {
									duration: MaterialEasing.expressiveFastSpatialTime
									easing.bezierCurve: MaterialEasing.expressiveFastSpatial
								}
							}
						}

						Behavior on implicitWidth {
							id: imWidthBehavior

							Anim {}
						}
					}

					// Input focus indicator (M3 focused state)
					Rectangle {
						anchors.fill: parent
						radius: 12
						color: "transparent"
						border.width: 2
						border.color: DynamicColors.palette.m3primary
						opacity: 0
						visible: hiddenInput.activeFocus

						Behavior on opacity {
							NumberAnimation { duration: 150 }
						}
					}

					Component.onCompleted: {
						if (hiddenInput.activeFocus) opacity = 1;
					}
				}

				// Message display: M3 Body Small (12sp, 500 weight) for error messages
				Text {
					id: messageDisplay

					Layout.alignment: Qt.AlignHCenter
					Layout.topMargin: 8

					text: {
						if (root.pam.lockMessage) {
							return root.pam.lockMessage;
						}
						if (root.pam.state === "error") {
							return "Authentication error";
						}
						if (root.pam.state === "fail") {
							return "Invalid password";
						}
						if (root.pam.state === "max") {
							return "Maximum attempts reached";
						}
						return "";
					}
					visible: text.length > 0
					font.pixelSize: 12
					font.weight: Font.Medium
					color: root.pam.state === "max" ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurfaceVariant
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					Layout.preferredWidth: 320
				}
			}
		}
		Component.onCompleted: hiddenInput.forceActiveFocus()
	}
}
