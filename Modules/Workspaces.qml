pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.Config
import qs.Components

Item {
	id: root

	property real activeWorkspaceMargin: Math.ceil(Appearance.padding.small / 2)
	required property PanelWindow bar
	readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
	readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.bar.screen)
	property int workspaceButtonWidth: rect.implicitHeight - root.activeWorkspaceMargin * 2
	property int workspaceIndexInGroup: (effectiveActiveWorkspaceId - 1) % root.workspacesShown
	readonly property list<var> workspaces: Hyprland.workspaces.values.filter(w => w.monitor === root.monitor)
	readonly property int workspacesShown: workspaces.length

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: (root.workspaceButtonWidth * root.workspacesShown) + root.activeWorkspaceMargin * 2

	Behavior on implicitWidth {
		Anim {
		}
	}

	CustomRect {
		id: rect

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: root.parent.height - ((Appearance.padding.small - 1) * 2)
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

				onIndexChanged: {
					console.log(indicator.indicatorPosition);
				}
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
					width: workspaceButtonWidth

					background: Item {
						id: workspaceButtonBackground

						implicitHeight: workspaceButtonWidth
						implicitWidth: workspaceButtonWidth

						CustomText {
							anchors.centerIn: parent
							color: (root.effectiveActiveWorkspaceId === button.modelData.id) ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
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
	}
}
