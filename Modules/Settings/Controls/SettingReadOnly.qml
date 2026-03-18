import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

Item {
	id: root

	required property string name
	required property string value

	Layout.fillWidth: true
	Layout.preferredHeight: row.implicitHeight + Appearance.padding.smaller * 2

	RowLayout {
		id: row

		anchors.left: parent.left
		anchors.margins: Appearance.padding.small
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter

		CustomText {
			Layout.fillWidth: true
			font.pointSize: Appearance.font.size.larger
			text: root.name
		}

		CustomText {
			color: DynamicColors.palette.m3onSurfaceVariant
			font.family: Appearance.font.family.mono
			font.pointSize: Appearance.font.size.normal
			text: root.value
		}
	}
}
