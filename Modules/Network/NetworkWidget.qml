import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules

Item {
	id: root

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: layout.implicitWidth

	RowLayout {
		id: layout

		anchors.bottom: parent.bottom
		anchors.top: parent.top

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			text: "android_wifi_4_bar"
		}
	}
}
