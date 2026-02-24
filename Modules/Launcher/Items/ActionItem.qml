import QtQuick
import qs.Modules.Launcher.Services
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property var list
	required property var modelData

	anchors.left: parent?.left
	anchors.right: parent?.right
	implicitHeight: Config.launcher.sizes.itemHeight

	StateLayer {
		function onClicked(): void {
			root.modelData?.onClicked(root.list);
		}

		radius: Appearance.rounding.normal
	}

	Item {
		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.larger
		anchors.margins: Appearance.padding.smaller
		anchors.rightMargin: Appearance.padding.larger

		MaterialIcon {
			id: icon

			anchors.verticalCenter: parent.verticalCenter
			font.pointSize: Appearance.font.size.extraLarge
			text: root.modelData?.icon ?? ""
		}

		Item {
			anchors.left: icon.right
			anchors.leftMargin: Appearance.spacing.normal
			anchors.verticalCenter: icon.verticalCenter
			implicitHeight: name.implicitHeight + desc.implicitHeight
			implicitWidth: parent.width - icon.width

			CustomText {
				id: name

				font.pointSize: Appearance.font.size.normal
				text: root.modelData?.name ?? ""
			}

			CustomText {
				id: desc

				anchors.top: name.bottom
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				text: root.modelData?.desc ?? ""
				width: root.width - icon.width - Appearance.rounding.normal * 2
			}
		}
	}
}
