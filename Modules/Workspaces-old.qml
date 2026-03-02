pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Config
import qs.Components

Item {
	id: itemRoot

	required property PanelWindow bar

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: workspacesRow.implicitWidth + 10

	Behavior on implicitWidth {
		NumberAnimation {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	Rectangle {
		id: root

		property HyprlandMonitor monitor: Hyprland.monitorFor(itemRoot.bar?.screen)

		function shouldShow(monitor) {
			Hyprland.refreshWorkspaces();
			Hyprland.refreshMonitors();
			if (monitor === root.monitor) {
				return true;
			} else {
				return false;
			}
		}

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 22
		radius: height / 2

		Behavior on color {
			CAnim {
			}
		}

		RowLayout {
			id: workspacesRow

			anchors.left: parent.left
			anchors.leftMargin: 6
			anchors.verticalCenter: parent.verticalCenter
			spacing: 8

			Repeater {
				model: Hyprland.workspaces

				RowLayout {
					id: workspaceIndicator

					required property var modelData

					visible: root.shouldShow(workspaceIndicator.modelData.monitor)

					CustomText {
						color: workspaceIndicator.modelData.id === Hyprland.focusedWorkspace.id ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
						font.pointSize: 12
						text: workspaceIndicator.modelData.name
						visible: true
					}

					Rectangle {
						border.color: workspaceIndicator.modelData.id === Hyprland.focusedWorkspace.id ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurfaceVariant
						border.width: 1
						color: "transparent"
						implicitHeight: 14
						implicitWidth: 14
						opacity: 1.0
						radius: height / 2
						scale: 1.0

						Behavior on border.color {
							ColorAnimation {
								duration: 150
								easing.type: Easing.InOutQuad
							}
						}
						NumberAnimation on opacity {
							duration: 200
							from: 0.0
							to: 1.0
						}
						NumberAnimation on scale {
							duration: 300
							easing.type: Easing.OutBack
							from: 0.0
							to: 1.0
						}

						CustomRect {
							anchors.centerIn: parent
							color: workspaceIndicator.modelData.id === Hyprland.focusedWorkspace.id ? DynamicColors.palette.m3primary : "transparent"
							implicitHeight: 8
							implicitWidth: 8
							radius: implicitHeight / 2
						}

						MouseArea {
							anchors.fill: parent

							onClicked: {
								workspaceIndicator.modelData.activate();
							}
						}
					}
				}
			}
		}
	}
}
