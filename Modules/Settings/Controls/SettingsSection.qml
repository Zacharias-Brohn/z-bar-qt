import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	id: root

	default property alias contentData: layout.data
	property real contentPadding: Appearance.padding.large

	Layout.fillWidth: true
	Layout.preferredHeight: layout.implicitHeight + contentPadding * 2
	color: DynamicColors.tPalette.m3surfaceContainer
	radius: Appearance.rounding.normal - Appearance.padding.smaller

	ColumnLayout {
		id: layout

		anchors.left: parent.left
		anchors.margins: root.contentPadding
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.normal
	}
}
