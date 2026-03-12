import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Helpers
import qs.Config

CustomRect {
	id: root

	property bool appIsActive: appToplevel?.toplevels.find(t => (t.activated == true)) !== undefined
	property var appListRoot
	property var appToplevel
	property real countDotHeight: 4
	property real countDotWidth: 10
	property var desktopEntry: DesktopEntries.heuristicLookup(appToplevel?.appId)
	property real iconSize: implicitHeight - 20
	readonly property bool isSeparator: appToplevel?.appId === "__dock_separator__"
	property int lastFocused: -1
	required property PersistentProperties visibilities

	implicitHeight: Config.dock.height
	implicitWidth: isSeparator ? 1 : implicitHeight
	radius: Appearance.rounding.normal - Appearance.padding.small

	Loader {
		active: !isSeparator
		anchors.centerIn: parent

		sourceComponent: ColumnLayout {
			IconImage {
				id: icon

				Layout.alignment: Qt.AlignHCenter
				implicitSize: root.iconSize
				source: Quickshell.iconPath(AppSearch.guessIcon(appToplevel?.appId), "image-missing")
			}

			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				spacing: 3

				Repeater {
					model: Math.min(appToplevel?.toplevels.length, 3)

					delegate: Rectangle {
						required property int index

						color: appIsActive ? DynamicColors.palette.m3primary : DynamicColors.tPalette.m3primary
						implicitHeight: root.countDotHeight
						implicitWidth: (appToplevel?.toplevels.length <= 3) ? root.countDotWidth : root.countDotHeight // Circles when too many
						radius: Appearance.rounding.full
					}
				}
			}
		}
	}

	StateLayer {
		onClicked: {
			if (appToplevel?.toplevels.length === 0) {
				root.desktopEntry?.execute();
				root.visibilities.dock = false;
				return;
			}
			lastFocused = (lastFocused + 1) % appToplevel?.toplevels.length;
			appToplevel?.toplevels[lastFocused].activate();
			root.visibilities.dock = false;
		}
	}

	Connections {
		function onApplicationsChanged() {
			root.desktopEntry = DesktopEntries.heuristicLookup(appToplevel?.appId);
		}

		target: DesktopEntries
	}

	Loader {
		active: isSeparator

		sourceComponent: DockSeparator {
		}

		anchors {
			fill: parent
		}
	}
}
