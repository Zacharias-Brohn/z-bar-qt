pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
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

	RowLayout {
		id: dockRow

		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		spacing: Appearance.spacing.small
	}
}
