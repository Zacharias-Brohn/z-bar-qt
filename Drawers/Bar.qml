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

		PanelWindow {
			id: bar

			property var root: Quickshell.shellDir
			property bool trayMenuVisible: false

			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || visibilities.resources ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
			WlrLayershell.namespace: "ZShell-Bar"
			color: "transparent"
			contentItem.focus: true
			screen: scope.modelData

			mask: Region {
				id: region

				height: bar.screen.height - backgroundRect.implicitHeight
				intersection: Intersection.Xor
				regions: popoutRegions.instances
				width: bar.width
				x: 0
				y: Config.barConfig.autoHide && !visibilities.bar ? 4 : 34
			}

			contentItem.Keys.onEscapePressed: {
				if (Config.barConfig.autoHide)
					visibilities.bar = false;
				visibilities.sidebar = false;
				visibilities.dashboard = false;
				visibilities.osd = false;
				visibilities.settings = false;
				visibilities.resources = false;
			}

			PanelWindow {
				id: exclusionZone

				WlrLayershell.exclusionMode: Config.barConfig.autoHide ? ExclusionMode.Ignore : ExclusionMode.Auto
				WlrLayershell.layer: WlrLayer.Bottom
				WlrLayershell.namespace: "ZShell-Bar-Exclusion"
				color: "transparent"
				implicitHeight: 34
				screen: bar.screen

				anchors {
					left: true
					right: true
					top: true
				}
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
					x: modelData.x
					y: modelData.y + backgroundRect.implicitHeight
				}
			}

			HyprlandFocusGrab {
				id: focusGrab

				active: visibilities.resources || visibilities.launcher || visibilities.sidebar || visibilities.dashboard || visibilities.settings || (panels.popouts.hasCurrent && panels.popouts.currentName.startsWith("traymenu"))
				windows: [bar]

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
					bar: backgroundRect
					visibilities: visibilities
				}

				Backgrounds {
					bar: backgroundRect
					panels: panels
					visibilities: visibilities
				}
			}

			Interactions {
				id: mouseArea

				anchors.fill: parent
				bar: barLoader
				panels: panels
				popouts: panels.popouts
				screen: scope.modelData
				visibilities: visibilities

				Panels {
					id: panels

					bar: backgroundRect
					screen: scope.modelData
					visibilities: visibilities
				}

				CustomRect {
					id: backgroundRect

					property Wrapper popouts: panels.popouts

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.topMargin: Config.barConfig.autoHide && !visibilities.bar ? -30 : 0
					color: "transparent"
					implicitHeight: 34
					radius: 0

					Behavior on anchors.topMargin {
						Anim {
						}
					}
					Behavior on color {
						CAnim {
						}
					}

					BarLoader {
						id: barLoader

						anchors.fill: parent
						bar: bar
						popouts: panels.popouts
						screen: scope.modelData
						visibilities: visibilities
					}
				}
			}
		}
	}
}
