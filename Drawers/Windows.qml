pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Daemons
import qs.Components
import qs.Modules
import qs.Modules.Bar
import qs.Config
import qs.Helpers
import qs.Drawers

Variants {
	model: Quickshell.screens

	Scope {
		id: scope

		required property var modelData

		Exclusions {
			bar: bar
			screen: scope.modelData
		}

		CustomWindow {
			id: win

			readonly property bool hasFullscreen: Hypr.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2)
			property var root: Quickshell.shellDir

			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || visibilities.resources ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
			color: "transparent"
			contentItem.focus: true
			mask: visibilities.isDrawing ? null : region
			name: "Bar"
			screen: scope.modelData

			contentItem.Keys.onEscapePressed: {
				if (Config.barConfig.autoHide)
					visibilities.bar = false;
				visibilities.sidebar = false;
				visibilities.dashboard = false;
				visibilities.osd = false;
				visibilities.settings = false;
				visibilities.resources = false;
			}
			onHasFullscreenChanged: {
				visibilities.launcher = false;
				visibilities.dashboard = false;
				visibilities.osd = false;
				visibilities.settings = false;
				visibilities.resources = false;
			}

			Region {
				id: region

				height: win.height - bar.implicitHeight - Config.barConfig.border
				intersection: Intersection.Xor
				regions: popoutRegions.instances
				width: win.width - Config.barConfig.border * 2
				x: Config.barConfig.border
				y: bar.implicitHeight
			}

			anchors {
				bottom: true
				left: true
				right: true
				top: true
			}

			Variants {
				id: popoutRegions

				model: panels.children

				Region {
					required property Item modelData

					height: modelData.height
					intersection: Intersection.Subtract
					width: modelData.width
					x: modelData.x + Config.barConfig.border
					y: modelData.y + bar.implicitHeight
				}
			}

			HyprlandFocusGrab {
				id: focusGrab

				active: visibilities.resources || visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || (panels.popouts.hasCurrent && panels.popouts.currentName.startsWith("traymenu"))
				windows: [win]

				onCleared: {
					visibilities.launcher = false;
					visibilities.sidebar = false;
					visibilities.dashboard = false;
					visibilities.osd = false;
					visibilities.settings = false;
					visibilities.resources = false;
					panels.popouts.hasCurrent = false;
				}
			}

			PersistentProperties {
				id: visibilities

				property bool bar
				property bool dashboard
				property bool isDrawing
				property bool launcher
				property bool notif: NotifServer.popups.length > 0
				property bool osd
				property bool resources
				property bool settings
				property bool sidebar

				Component.onCompleted: Visibilities.load(scope.modelData, this)
			}

			Binding {
				property: "bar"
				target: visibilities
				value: visibilities.sidebar || visibilities.dashboard || visibilities.osd || visibilities.notif || visibilities.resources
				when: Config.barConfig.autoHide
			}

			Item {
				anchors.fill: parent
				layer.enabled: true
				opacity: Appearance.transparency.enabled ? DynamicColors.transparency.base : 1

				layer.effect: MultiEffect {
					blurMax: 32
					shadowColor: Qt.alpha(DynamicColors.palette.m3shadow, 1)
					shadowEnabled: true
				}

				Border {
					bar: bar
					visibilities: visibilities
				}

				Backgrounds {
					bar: bar
					panels: panels
					visibilities: visibilities
				}
			}

			Drawing {
				id: drawing

				anchors.fill: parent
				z: 2
			}

			DrawingInput {
				id: input

				bar: bar
				drawing: drawing
				panels: panels
				popout: panels.drawing
				visibilities: visibilities
				z: 2
			}

			Interactions {
				id: mouseArea

				anchors.fill: parent
				bar: bar
				drawing: drawing
				input: input
				panels: panels
				popouts: panels.popouts
				screen: scope.modelData
				visibilities: visibilities
				z: 1

				Panels {
					id: panels

					bar: bar
					drawingItem: drawing
					screen: scope.modelData
					visibilities: visibilities
				}

				BarLoader {
					id: bar

					anchors.left: parent.left
					anchors.right: parent.right
					popouts: panels.popouts
					screen: scope.modelData
					visibilities: visibilities
				}
			}
		}
	}
}
