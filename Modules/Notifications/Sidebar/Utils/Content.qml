import qs.Modules.Notifications.Sidebar.Utils.Cards
import qs.Config
import QtQuick
import QtQuick.Layouts

Item {
	id: root

	required property Item popouts
	required property var props
	required property var visibilities

	implicitHeight: layout.implicitHeight
	implicitWidth: layout.implicitWidth

	ColumnLayout {
		id: layout

		anchors.fill: parent
		spacing: 8

		IdleInhibit {
		}

		Toggles {
			popouts: root.popouts
			visibilities: root.visibilities
		}
	}
}
