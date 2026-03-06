pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import QtQml
import qs.Effects
import qs.Config

PanelWindow {
	id: root

	property color backgroundColor: DynamicColors.tPalette.m3surface
	required property PanelWindow bar
	property int biggestWidth: 0
	property color disabledHighlightColor: DynamicColors.layer(DynamicColors.palette.m3primaryContainer, 0)
	property color disabledTextColor: DynamicColors.layer(DynamicColors.palette.m3onSurface, 0)
	property int entryHeight: 30
	property alias focusGrab: grab.active
	property color highlightColor: DynamicColors.tPalette.m3primaryContainer
	property int menuItemCount: menuOpener.children.values.length
	property var menuStack: []
	property real scaleValue: 0
	property color textColor: DynamicColors.palette.m3onSurface
	required property point trayItemRect
	required property QsMenuHandle trayMenu

	signal finishedLoading
	signal menuActionTriggered

	function goBack() {
		if (root.menuStack.length > 0) {
			menuChangeAnimation.start();
			root.biggestWidth = 0;
			root.trayMenu = root.menuStack.pop();
			listLayout.positionViewAtBeginning();
			backEntry.visible = false;
		}
	}

	function updateMask() {
		root.mask.changed();
	}

	color: "transparent"

	// onTrayMenuChanged: {
	//     listLayout.forceLayout();
	// }

	visible: false

	mask: Region {
		id: mask

		item: menuRect
	}

	onMenuActionTriggered: {
		if (root.menuStack.length > 0) {
			backEntry.visible = true;
		}
	}
	onVisibleChanged: {
		if (!visible)
			root.menuStack.pop();
		backEntry.visible = false;

		openAnim.start();
	}

	QsMenuOpener {
		id: menuOpener

		menu: root.trayMenu
	}

	anchors {
		bottom: true
		left: true
		right: true
		top: true
	}

	HyprlandFocusGrab {
		id: grab

		active: false
		windows: [root]

		onCleared: {
			closeAnim.start();
		}
	}

	SequentialAnimation {
		id: menuChangeAnimation

		ParallelAnimation {
			NumberAnimation {
				duration: MaterialEasing.standardTime / 2
				easing.bezierCurve: MaterialEasing.expressiveEffects
				from: 0
				property: "x"
				target: translateAnim
				to: -listLayout.width / 2
			}

			NumberAnimation {
				duration: MaterialEasing.standardTime / 2
				easing.bezierCurve: MaterialEasing.standard
				from: 1
				property: "opacity"
				target: columnLayout
				to: 0
			}
		}

		PropertyAction {
			property: "menu"
			target: columnLayout
		}

		ParallelAnimation {
			NumberAnimation {
				duration: MaterialEasing.standardTime / 2
				easing.bezierCurve: MaterialEasing.standard
				from: 0
				property: "opacity"
				target: columnLayout
				to: 1
			}

			NumberAnimation {
				duration: MaterialEasing.standardTime / 2
				easing.bezierCurve: MaterialEasing.expressiveEffects
				from: listLayout.width / 2
				property: "x"
				target: translateAnim
				to: 0
			}
		}
	}

	ParallelAnimation {
		id: closeAnim

		onFinished: {
			root.visible = false;
		}

		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
			property: "implicitHeight"
			target: menuRect
			to: 0
		}

		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
			from: 1
			property: "opacity"
			targets: [menuRect, shadowRect]
			to: 0
		}
	}

	ParallelAnimation {
		id: openAnim

		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
			from: 0
			property: "implicitHeight"
			target: menuRect
			to: listLayout.contentHeight + (root.menuStack.length > 0 ? root.entryHeight + 10 : 10)
		}

		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
			from: 0
			property: "opacity"
			targets: [menuRect, shadowRect]
			to: 1
		}
	}

	ShadowRect {
		id: shadowRect

		anchors.fill: menuRect
		radius: menuRect.radius
	}

	Rectangle {
		id: menuRect

		clip: true
		color: root.backgroundColor
		implicitHeight: listLayout.contentHeight + (root.menuStack.length > 0 ? root.entryHeight + 10 : 10)
		implicitWidth: listLayout.contentWidth + 10
		radius: 8
		x: Math.round(root.trayItemRect.x - (menuRect.implicitWidth / 2) + 11)
		y: Math.round(root.trayItemRect.y - 5)

		Behavior on implicitHeight {
			NumberAnimation {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}
		Behavior on implicitWidth {
			NumberAnimation {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}

		ColumnLayout {
			id: columnLayout

			anchors.fill: parent
			anchors.margins: 5
			spacing: 0

			transform: [
				Translate {
					id: translateAnim

					x: 0
					y: 0
				}
			]

			ListView {
				id: listLayout

				Layout.fillWidth: true
				Layout.preferredHeight: contentHeight
				contentHeight: contentItem.childrenRect.height
				contentWidth: root.biggestWidth
				model: menuOpener.children
				spacing: 0

				delegate: Rectangle {
					id: menuItem

					property var child: QsMenuOpener {
						menu: menuItem.modelData
					}
					property bool containsMouseAndEnabled: mouseArea.containsMouse && menuItem.modelData.enabled
					property bool containsMouseAndNotEnabled: mouseArea.containsMouse && !menuItem.modelData.enabled
					required property int index
					required property QsMenuEntry modelData

					anchors.left: parent.left
					anchors.right: parent.right
					color: menuItem.modelData.isSeparator ? "#20FFFFFF" : containsMouseAndEnabled ? root.highlightColor : containsMouseAndNotEnabled ? root.disabledHighlightColor : "transparent"
					height: menuItem.modelData.isSeparator ? 1 : root.entryHeight
					radius: 4
					visible: true
					width: widthMetrics.width + (menuItem.modelData.icon ?? "" ? 30 : 0) + (menuItem.modelData.hasChildren ? 30 : 0) + 20

					Behavior on color {
						CAnim {
							duration: 150
						}
					}

					Component.onCompleted: {
						var biggestWidth = root.biggestWidth;
						var currentWidth = widthMetrics.width + (menuItem.modelData.icon ?? "" ? 30 : 0) + (menuItem.modelData.hasChildren ? 30 : 0) + 20;
						if (currentWidth > biggestWidth) {
							root.biggestWidth = currentWidth;
						}
					}

					TextMetrics {
						id: widthMetrics

						text: menuItem.modelData.text
					}

					MouseArea {
						id: mouseArea

						acceptedButtons: Qt.LeftButton
						anchors.fill: parent
						hoverEnabled: true
						preventStealing: true
						propagateComposedEvents: true

						onClicked: {
							if (!menuItem.modelData.hasChildren) {
								if (menuItem.modelData.enabled) {
									menuItem.modelData.triggered();
									closeAnim.start();
								}
							} else {
								root.menuStack.push(root.trayMenu);
								menuChangeAnimation.start();
								root.biggestWidth = 0;
								root.trayMenu = menuItem.modelData;
								listLayout.positionViewAtBeginning();
								root.menuActionTriggered();
							}
						}
					}

					RowLayout {
						anchors.fill: parent

						Text {
							id: menuText

							Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
							Layout.leftMargin: 10
							color: menuItem.modelData.enabled ? root.textColor : root.disabledTextColor
							text: menuItem.modelData.text
						}

						Image {
							id: iconImage

							Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
							Layout.maximumHeight: 20
							Layout.maximumWidth: 20
							Layout.rightMargin: 10
							fillMode: Image.PreserveAspectFit
							layer.enabled: true
							source: menuItem.modelData.icon
							sourceSize.height: height
							sourceSize.width: width

							layer.effect: ColorOverlay {
								color: menuItem.modelData.enabled ? "white" : "gray"
							}
						}

						Text {
							id: textArrow

							Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
							Layout.bottomMargin: 5
							Layout.maximumHeight: 20
							Layout.maximumWidth: 20
							Layout.rightMargin: 10
							color: menuItem.modelData.enabled ? "white" : "gray"
							text: ""
							visible: menuItem.modelData.hasChildren ?? false
						}
					}
				}
			}

			Rectangle {
				id: backEntry

				Layout.fillWidth: true
				Layout.preferredHeight: root.entryHeight
				color: mouseAreaBack.containsMouse ? "#15FFFFFF" : "transparent"
				radius: 4
				visible: false

				MouseArea {
					id: mouseAreaBack

					anchors.fill: parent
					hoverEnabled: true

					onClicked: {
						root.goBack();
					}
				}

				Text {
					anchors.fill: parent
					anchors.leftMargin: 10
					color: "white"
					text: "Back "
					verticalAlignment: Text.AlignVCenter
				}
			}
		}
	}
}
