import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import QtQuick
import qs.Config
import qs.Helpers
import qs.Daemons
import qs.Effects

Scope {
	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: root
			color: "transparent"
			anchors {
				top: true
				right: true
				left: true
				bottom: true
			}

			WlrLayershell.namespace: "ZShell-Notifs"
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
			property bool centerShown: false
			property alias posX: backgroundRect.x
			visible: false

			mask: Region { item: backgroundRect }

			GlobalShortcut {
				appid: "zshell-nc"
				name: "toggle-nc"
				onPressed: {
					root.centerShown = !root.centerShown;
				}
			}

			onVisibleChanged: {
				if ( root.visible ) {
					showAnimation.start();
				}
			}

			onCenterShownChanged: {
				if ( !root.centerShown ) {
					closeAnimation.start();
					closeTimer.start();
				} else if ( Hypr.getActiveScreen() === root.screen ) {
					root.visible = true;
				}
			}

			Keys.onPressed: {
				if ( event.key === Qt.Key_Escape ) {
					root.centerShown = false;
					event.accepted = true;
				}
			}

			Timer {
				id: closeTimer
				interval: 300
				onTriggered: {
					root.visible = false;
				}
			}

			NumberAnimation {
				id: showAnimation
				target: backgroundRect
				property: "x"
				to: Math.round(root.screen.width - backgroundRect.implicitWidth - 10)
				from: root.screen.width
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
				onStopped: {
					focusGrab.active = true;
				}
			}

			NumberAnimation {
				id: closeAnimation
				target: backgroundRect
				property: "x"
				from: root.screen.width - backgroundRect.implicitWidth - 10
				to: root.screen.width
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}

			HyprlandFocusGrab {
				id: focusGrab
				active: false
				windows: [ root ]
				onCleared: {
					root.centerShown = false;
				}
			}

			TrackedNotification {
				centerShown: root.centerShown
				screen: root.screen
			}

			ShadowRect {
				anchors.fill: backgroundRect
				radius: backgroundRect.radius
			}

			Rectangle {
				id: backgroundRect
				y: 10
				x: Screen.width
				z: 1

				property color backgroundColor: Config.useDynamicColors ? DynamicColors.tPalette.m3surface : Config.baseBgColor

				implicitWidth: 400
				implicitHeight: root.height - 20
				color: backgroundColor
				radius: 8
				border.color: "#555555"
				border.width: Config.useDynamicColors ? 0 : 1
				ColumnLayout {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 10

					NotificationCenterHeader { }

					Rectangle {
						color: "#333333"
						Layout.preferredHeight: Config.useDynamicColors ? 0 : 1
						Layout.fillWidth: true
					}

					Flickable {
						Layout.fillWidth: true
						Layout.fillHeight: true
						pixelAligned: true
						contentHeight: notificationColumn.implicitHeight
						clip: true

						Column {
							id: notificationColumn
							width: parent.width
							spacing: 10

							add: Transition {
								NumberAnimation {
									properties: "x";
									duration: 300;
									easing.type: Easing.OutCubic
								}
							}

							move: Transition {
								NumberAnimation {
									properties: "x";
									duration: 200;
									easing.type: Easing.OutCubic
								}
							}

							GroupListView { }

						}
					}
				}
			}
		}
	}
}
