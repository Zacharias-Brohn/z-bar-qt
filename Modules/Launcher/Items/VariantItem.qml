import QtQuick
import qs.Components
import qs.Modules.Launcher.Services
import qs.Config

Item {
	id: root

	required property var list
	required property SchemeVariants.Variant modelData

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

		Column {
			anchors.left: icon.right
			anchors.leftMargin: Appearance.spacing.larger
			anchors.verticalCenter: icon.verticalCenter
			spacing: 0
			width: parent.width - icon.width - anchors.leftMargin - (current.active ? current.width + Appearance.spacing.normal : 0)

			CustomText {
				font.pointSize: Appearance.font.size.normal
				text: root.modelData?.name ?? ""
			}

			CustomText {
				anchors.left: parent.left
				anchors.right: parent.right
				color: DynamicColors.palette.m3outline
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.small
				text: root.modelData?.description ?? ""
			}
		}

		Loader {
			id: current

			active: root.modelData?.variant === Config.colors.schemeType
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter

			sourceComponent: MaterialIcon {
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.large
				text: "check"
			}
		}
	}
}
