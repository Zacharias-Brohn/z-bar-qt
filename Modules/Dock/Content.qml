pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Modules.Dock.Parts
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	readonly property int padding: Appearance.padding.small
	required property var panels
	readonly property int rounding: Appearance.rounding.large
	required property PersistentProperties visibilities

	implicitHeight: Config.dock.height + root.padding * 2
	implicitWidth: dockRow.implicitWidth + root.padding * 2

	CustomListView {
		id: dockRow

		anchors.centerIn: parent
		implicitHeight: Config.dock.height
		implicitWidth: contentWidth
		orientation: ListView.Horizontal
		spacing: Appearance.padding.smaller

		delegate: DockAppButton {
			required property var modelData

			appListRoot: root
			appToplevel: modelData
			visibilities: root.visibilities
		}
		Behavior on implicitWidth {
			Anim {
			}
		}
		model: ScriptModel {
			objectProp: "appId"
			values: TaskbarApps.apps
		}
	}
}
