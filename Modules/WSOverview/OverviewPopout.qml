import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Components
import qs.Modules
import qs.Helpers

Item {
	id: root

	required property Item wrapper
	required property ShellScreen screen

	implicitWidth: layout.implicitWidth + 16
	implicitHeight: layout.implicitHeight + 16

	GridLayout {
		id: layout
		anchors.centerIn: parent

		columnSpacing: 8
		rowSpacing: 8

		Repeater {
			model: Hypr.workspaces

			CustomRect {
				id: workspacePreview
				required property HyprlandWorkspace modelData

				border.color: "white"
				border.width: 1
				radius: 8
				Layout.preferredWidth: 320 + 10
				Layout.preferredHeight: 180 + 10

				Repeater {
					model: workspacePreview.modelData.toplevels

					Item {
						id: preview
						anchors.fill: parent
						anchors.margins: 5

						required property HyprlandToplevel modelData
						property rect appPosition: {
							let {
								at: [cx, cy],
								size: [cw, ch]
							} = modelData.lastIpcObject;

							cx -= modelData.monitor.x;
							cy -= modelData.monitor.y;

							return Qt.rect( (cx / 8), (cy / 8), (cw / 8), (ch / 8) )
						}

						CustomRect {
							border.color: DynamicColors.tPalette.m3outline
							border.width: 1
							radius: 4
							implicitWidth: preview.appPosition.width
							implicitHeight: preview.appPosition.height

							x: preview.appPosition.x
							y: preview.appPosition.y - 3.4

							ScreencopyView {
								id: previewCopy
								anchors.fill: parent

								captureSource: preview.modelData.wayland
								live: true
							}
						}
					}
				}
			}
		}
	}
}
