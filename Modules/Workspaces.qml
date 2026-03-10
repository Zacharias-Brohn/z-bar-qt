pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Config
import qs.Components

Item {
	id: root

	property real activeWorkspaceMargin: Math.ceil(Appearance.padding.small / 2)
	readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
	readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
	required property ShellScreen screen
	property int workspaceButtonWidth: bgRect.implicitHeight - root.activeWorkspaceMargin * 2
	property int workspaceIndexInGroup: (effectiveActiveWorkspaceId - 1) % root.workspacesShown
	readonly property list<var> workspaces: Hyprland.workspaces.values.filter(w => w.monitor === root.monitor)
	readonly property int workspacesShown: workspaces.length

	height: implicitHeight
	implicitHeight: Config.barConfig.height + Math.max(Appearance.padding.smaller, Config.barConfig.border) * 2
	implicitWidth: (root.workspaceButtonWidth * root.workspacesShown) + root.activeWorkspaceMargin * 2

	Behavior on implicitWidth {
		Anim {
		}
	}

	CustomRect {
		id: bgRect

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: root.implicitHeight - ((Appearance.padding.small - 1) * 2)
		radius: height / 2

		CustomRect {
			id: indicator

			property real indicatorLength: (Math.abs(idxPair.idx1 - idxPair.idx2) + 1) * root.workspaceButtonWidth
			property real indicatorPosition: Math.min(idxPair.idx1, idxPair.idx2) * root.workspaceButtonWidth + root.activeWorkspaceMargin
			property real indicatorThickness: root.workspaceButtonWidth

			anchors.verticalCenter: parent.verticalCenter
			color: DynamicColors.palette.m3primary
			implicitHeight: indicatorThickness
			implicitWidth: indicatorLength
			radius: Appearance.rounding.full
			x: indicatorPosition
			z: 2

			AnimatedTabIndexPair {
				id: idxPair

				index: root.workspaces.findIndex(w => w.active)
			}
		}

		Grid {
			anchors.fill: parent
			anchors.margins: root.activeWorkspaceMargin
			columnSpacing: 0
			columns: root.workspacesShown
			rowSpacing: 0
			rows: 1
			z: 3

			Repeater {
				model: root.workspaces

				Button {
					id: button

					required property int index
					required property HyprlandWorkspace modelData

					implicitHeight: indicator.indicatorThickness
					implicitWidth: indicator.indicatorThickness
					width: root.workspaceButtonWidth

					background: Item {
						id: workspaceButtonBackground

						implicitHeight: root.workspaceButtonWidth
						implicitWidth: root.workspaceButtonWidth

						CustomText {
							anchors.centerIn: parent
							color: button.modelData.active ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
							elide: Text.ElideRight
							horizontalAlignment: Text.AlignHCenter
							text: button.modelData.name
							verticalAlignment: Text.AlignVCenter
							z: 3
						}
					}

					onPressed: {
						Hyprland.dispatch(`workspace ${button.modelData.name}`);
					}
				}
			}
		}

		Item {
			id: activeTextSource

			anchors.fill: parent
			anchors.margins: root.activeWorkspaceMargin
			layer.enabled: true
			visible: false
			z: 4

			Grid {
				anchors.fill: parent
				columnSpacing: 0
				columns: root.workspacesShown
				rowSpacing: 0
				rows: 1

				Repeater {
					model: root.workspaces

					Item {
						id: activeWorkspace

						required property int index
						required property HyprlandWorkspace modelData

						implicitHeight: indicator.indicatorThickness
						implicitWidth: indicator.indicatorThickness
						width: root.workspaceButtonWidth

						CustomText {
							anchors.centerIn: parent
							color: DynamicColors.palette.m3onPrimary
							elide: Text.ElideRight
							horizontalAlignment: Text.AlignHCenter
							text: activeWorkspace.modelData.name
							verticalAlignment: Text.AlignVCenter
						}
					}
				}
			}
		}

		Item {
			id: indicatorMask

			anchors.fill: bgRect
			layer.enabled: true
			visible: false

			CustomRect {
				color: "white"
				height: indicator.height
				radius: indicator.radius
				width: indicator.width
				x: indicator.x
				y: indicator.y
			}
		}

		MultiEffect {
			anchors.fill: activeTextSource
			maskEnabled: true
			maskInverted: false
			maskSource: indicatorMask
			source: activeTextSource
			z: 5
		}
	}
}
