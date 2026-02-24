import qs.Components
import qs.Config
import QtQuick
import QtQuick.Layouts

Item {
	id: root

	required property Props props
	required property var visibilities

	ColumnLayout {
		id: layout

		anchors.fill: parent
		spacing: 8

		CustomRect {
			Layout.fillHeight: true
			Layout.fillWidth: true
			color: DynamicColors.tPalette.m3surfaceContainerLow
			radius: 8

			NotifDock {
				props: root.props
				visibilities: root.visibilities
			}
		}

		CustomRect {
			Layout.fillWidth: true
			Layout.topMargin: 8 - layout.spacing
			color: DynamicColors.tPalette.m3outlineVariant
			implicitHeight: 1
		}
	}
}
