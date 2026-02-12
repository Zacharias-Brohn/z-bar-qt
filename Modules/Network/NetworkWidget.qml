import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules

Item {
	id: root

	anchors.top: parent.top
	anchors.bottom: parent.bottom

	implicitWidth: layout.implicitWidth

	RowLayout {
		id: layout
		anchors.top: parent.top
		anchors.bottom: parent.bottom

		MaterialIcon {
			text: "android_wifi_4_bar"
			Layout.alignment: Qt.AlignVCenter
		}
	}
}
