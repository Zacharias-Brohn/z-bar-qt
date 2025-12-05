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
	required property Scope scope

	property string buffer

	color: "transparent"

	Connections {
		target: root.pam

		function onBufferChanged(): void {
			if (root.pam.buffer.length > root.buffer.length) {
				charList.bindImWidth();
			} else if (root.pam.buffer.length === 0) {
				charList.implicitWidth = charList.implicitWidth;
			}

			root.buffer = root.pam.buffer;
		}
	}

	Timer {
		interval: 5
		running: true
		repeat: false
		onTriggered: {
			if ( Config.lock.fixLockScreen && root.scope.seenOnce === 0 ) {
				Quickshell.execDetached(["hyprctl", "keyword", "misc:session_lock_xray", "false;"]);
				root.scope.seenOnce += 1;
			}
		}
	}

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

		live: false

		anchors.fill: parent
		captureSource: root.screen
		opacity: 1
		visible: !Config.lock.useWallpaper

		layer.enabled: true
		layer.effect: MultiEffect {
			autoPaddingEnabled: false
			blurEnabled: true
			blur: 0.8
			blurMax: 64
			blurMultiplier: 1
			brightness: 0
		}
	}

	Image {
		id: backgroundImage
		anchors.fill: parent
		asynchronous: false
		cache: false
		source: WallpaperPath.currentWallpaperPath
		sourceSize.width: root.screen.width
		sourceSize.height: root.screen.height
		visible: Config.lock.useWallpaper

		Component.onCompleted: {
			console.log(source);
		}
	}

	Rectangle {
		id: overlay
		anchors.fill: parent
		color: "transparent"

		visible: background.hasContent

		Rectangle {
			id: contentBox
			anchors.bottom: !Config.lock.useWallpaper ? "" : parent.bottom
			anchors.centerIn: !Config.lock.useWallpaper ? parent : ""
			anchors.horizontalCenter: !Config.lock.useWallpaper ? "" : parent.horizontalCenter

			color: DynamicColors.tPalette.m3surfaceContainer
			radius: 28

			implicitWidth: Math.floor(childrenRect.width + 48)
			implicitHeight: Math.floor(childrenRect.height + 64)

			layer.enabled: true
			layer.effect: MultiEffect {
				source: contentBox
				blurEnabled: false
				blurMax: 12
				shadowBlur: 1
				shadowColor: DynamicColors.palette.m3shadow
				shadowOpacity: 1
				shadowEnabled: true
				autoPaddingEnabled: true
			}

			ColumnLayout {
				id: mainLayout
				anchors.centerIn: parent
				width: childrenRect.width
				spacing: 0

				RowLayout {
					Layout.alignment: Qt.AlignHCenter
					Layout.bottomMargin: 16
					spacing: 16

					UserImage {
						Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
						Layout.bottomMargin: 16
						Layout.preferredWidth: 128
						Layout.preferredHeight: 128
					}

					LockTime {
						Layout.alignment: Qt.AlignHCenter
						Layout.bottomMargin: 8
					}
				}

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

					clip: true

					Behavior on border.color {
						ColorAnimation { duration: 150 }
					}

					transform: Translate {
						id: wobbleTransform
						x: 0
					}

					SequentialAnimation {
						id: wobbleAnimation

						ColorAnimation {
							target: inputContainer
							property: "color"
							to: DynamicColors.tPalette.m3onError
							duration: MaterialEasing.expressiveEffectsTime
						}
						ParallelAnimation {
							NumberAnimation {
								target: wobbleTransform
								property: "x"
								to: -8
								duration: MaterialEasing.expressiveFastSpatialTime / 4
								easing.bezierCurve: MaterialEasing.expressiveFastSpatial
							}
						}
						NumberAnimation {
							target: wobbleTransform
							property: "x"
							to: 8
							duration: MaterialEasing.expressiveFastSpatialTime / 4
							easing.bezierCurve: MaterialEasing.expressiveFastSpatial
						}
						NumberAnimation {
							target: wobbleTransform
							property: "x"
							to: -8
							duration: MaterialEasing.expressiveFastSpatialTime / 4
							easing.bezierCurve: MaterialEasing.expressiveFastSpatial
						}
						NumberAnimation {
							target: wobbleTransform
							property: "x"
							to: 0
							duration: MaterialEasing.expressiveFastSpatialTime / 4
							easing.bezierCurve: MaterialEasing.expressiveFastSpatial
						}
						ColorAnimation {
							target: inputContainer
							property: "color"
							to: DynamicColors.tPalette.m3surfaceContainerHigh
							duration: MaterialEasing.expressiveEffectsTime
						}
					}

					Connections {
						target: root.pam

						function onStateChanged(): void {
							if (root.pam.state === "error" || root.pam.state === "fail") {
								wobbleAnimation.start();
							}
						}
					}

					CustomText {
						id: messageDisplay

						anchors.centerIn: inputContainer

						text: {
							if ( root.pam.buffer.length > 0 || root.pam.passwd.active ) {
								return "";
							}
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
							return "Enter your password";
						}
						visible: true
						font.pointSize: 14
						font.weight: Font.Medium

						animate: true

						Behavior on text {
							SequentialAnimation {
								OAnim {
									target: messageDisplay
									property: "opacity"
									to: 0
								}
								PropertyAction {}
								OAnim {
									target: messageDisplay
									property: "opacity"
									to: 1
								}
							}
						}

						component OAnim: NumberAnimation {
							target: messageDisplay
							property: "opacity"
							duration: 100
						}

						color: root.pam.state === "max" ? DynamicColors.palette.m3error : DynamicColors.palette.m3onSurfaceVariant
						wrapMode: Text.WordWrap
						horizontalAlignment: Text.AlignHCenter
					}

					ListView {
						id: charList

						readonly property int fullWidth: count * (implicitHeight + spacing)

						function bindImWidth(): void {
							imWidthBehavior.enabled = false;
							implicitWidth = Qt.binding(() => fullWidth);
							imWidthBehavior.enabled = true;
						}

						anchors.centerIn: parent
						anchors.horizontalCenterOffset: implicitWidth > inputContainer.width - 20 ? -(implicitWidth - inputContainer.width + 20) / 2 : 0

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
				}
			}
		}
		Component.onCompleted: hiddenInput.forceActiveFocus()
	}
}
