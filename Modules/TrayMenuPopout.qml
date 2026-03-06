pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

StackView {
	id: root

	property int biggestWidth: 0
	required property Item popouts
	property int rootWidth: 0
	required property QsMenuHandle trayItem

	implicitHeight: currentItem.implicitHeight
	implicitWidth: currentItem.implicitWidth

	initialItem: SubMenu {
		handle: root.trayItem
	}
	popEnter: NoAnim {
	}
	popExit: NoAnim {
	}
	pushEnter: NoAnim {
	}
	pushExit: NoAnim {
	}

	Component {
		id: subMenuComp

		SubMenu {
		}
	}

	component NoAnim: Transition {
		NumberAnimation {
			duration: 0
		}
	}
	component SubMenu: Column {
		id: menu

		required property QsMenuHandle handle
		property bool isSubMenu
		property bool shown

		opacity: shown ? 1 : 0
		padding: 0
		scale: shown ? 1 : 0.8
		spacing: 4

		Behavior on opacity {
			Anim {
			}
		}
		Behavior on scale {
			Anim {
			}
		}

		Component.onCompleted: shown = true
		StackView.onActivating: shown = true
		StackView.onDeactivating: shown = false
		StackView.onRemoved: destroy()

		QsMenuOpener {
			id: menuOpener

			menu: menu.handle
		}

		Repeater {
			model: menuOpener.children

			CustomRect {
				id: item

				required property QsMenuEntry modelData

				color: modelData.isSeparator ? DynamicColors.palette.m3outlineVariant : "transparent"
				implicitHeight: modelData.isSeparator ? 1 : children.implicitHeight
				implicitWidth: root.biggestWidth
				radius: 4

				Loader {
					id: children

					active: !item.modelData.isSeparator
					anchors.left: parent.left
					anchors.right: parent.right
					asynchronous: true

					sourceComponent: Item {
						implicitHeight: 30

						StateLayer {
							function onClicked(): void {
								const entry = item.modelData;
								if (entry.hasChildren) {
									root.rootWidth = root.biggestWidth;
									root.biggestWidth = 0;
									root.push(subMenuComp.createObject(null, {
										handle: entry,
										isSubMenu: true
									}));
								} else {
									item.modelData.triggered();
									root.popouts.hasCurrent = false;
								}
							}

							disabled: !item.modelData.enabled
							radius: item.radius
						}

						Loader {
							id: icon

							active: item.modelData.icon !== ""
							anchors.right: parent.right
							anchors.rightMargin: 10
							anchors.verticalCenter: parent.verticalCenter
							asynchronous: true

							sourceComponent: Item {
								implicitHeight: label.implicitHeight
								implicitWidth: label.implicitHeight

								IconImage {
									id: iconImage

									implicitSize: parent.implicitHeight
									source: item.modelData.icon
									visible: false
								}

								MultiEffect {
									anchors.fill: iconImage
									colorization: 1.0
									colorizationColor: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
									source: iconImage
								}
							}
						}

						CustomText {
							id: label

							anchors.left: parent.left
							anchors.leftMargin: 10
							anchors.verticalCenter: parent.verticalCenter
							color: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
							text: labelMetrics.elidedText
						}

						TextMetrics {
							id: labelMetrics

							font.family: label.font.family
							font.pointSize: label.font.pointSize
							text: item.modelData.text

							Component.onCompleted: {
								var biggestWidth = root.biggestWidth;
								var currentWidth = labelMetrics.width + (item.modelData.icon ?? "" ? 30 : 0) + (item.modelData.hasChildren ? 30 : 0) + 20;
								if (currentWidth > biggestWidth) {
									root.biggestWidth = currentWidth;
								}
							}
						}

						Loader {
							id: expand

							active: item.modelData.hasChildren
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							asynchronous: true

							sourceComponent: MaterialIcon {
								color: item.modelData.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3outline
								text: "chevron_right"
							}
						}
					}
				}
			}
		}

		Loader {
			active: menu.isSubMenu
			asynchronous: true

			sourceComponent: Item {
				implicitHeight: back.implicitHeight + 2 / 2
				implicitWidth: back.implicitWidth

				Item {
					anchors.bottom: parent.bottom
					implicitHeight: back.implicitHeight
					implicitWidth: back.implicitWidth + 10

					CustomRect {
						anchors.fill: parent
						color: DynamicColors.palette.m3secondaryContainer
						radius: 4

						StateLayer {
							function onClicked(): void {
								root.pop();
								root.biggestWidth = root.rootWidth;
							}

							color: DynamicColors.palette.m3onSecondaryContainer
							radius: parent.radius
						}
					}

					Row {
						id: back

						anchors.verticalCenter: parent.verticalCenter

						MaterialIcon {
							anchors.verticalCenter: parent.verticalCenter
							color: DynamicColors.palette.m3onSecondaryContainer
							text: "chevron_left"
						}

						CustomText {
							anchors.verticalCenter: parent.verticalCenter
							color: DynamicColors.palette.m3onSecondaryContainer
							text: qsTr("Back")
						}
					}
				}
			}
		}
	}
}
