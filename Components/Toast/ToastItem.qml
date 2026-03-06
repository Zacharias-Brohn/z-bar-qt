import ZShell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

CustomRect {
	id: root

	required property Toast modelData

	anchors.left: parent.left
	anchors.right: parent.right
	border.color: {
		let colour = DynamicColors.palette.m3outlineVariant;
		if (root.modelData.type === Toast.Success)
			colour = DynamicColors.palette.m3success;
		if (root.modelData.type === Toast.Warning)
			colour = DynamicColors.palette.m3secondaryContainer;
		if (root.modelData.type === Toast.Error)
			colour = DynamicColors.palette.m3error;
		return Qt.alpha(colour, 0.3);
	}
	border.width: 1
	color: {
		if (root.modelData.type === Toast.Success)
			return DynamicColors.palette.m3successContainer;
		if (root.modelData.type === Toast.Warning)
			return DynamicColors.palette.m3secondary;
		if (root.modelData.type === Toast.Error)
			return DynamicColors.palette.m3errorContainer;
		return DynamicColors.palette.m3surface;
	}
	implicitHeight: layout.implicitHeight + Appearance.padding.smaller * 2
	radius: Appearance.rounding.normal

	Behavior on border.color {
		CAnim {
		}
	}

	Elevation {
		anchors.fill: parent
		level: 3
		opacity: parent.opacity
		radius: parent.radius
		z: -1
	}

	RowLayout {
		id: layout

		anchors.fill: parent
		anchors.leftMargin: Appearance.padding.normal
		anchors.margins: Appearance.padding.smaller
		anchors.rightMargin: Appearance.padding.normal
		spacing: Appearance.spacing.normal

		CustomRect {
			color: {
				if (root.modelData.type === Toast.Success)
					return DynamicColors.palette.m3success;
				if (root.modelData.type === Toast.Warning)
					return DynamicColors.palette.m3secondaryContainer;
				if (root.modelData.type === Toast.Error)
					return DynamicColors.palette.m3error;
				return DynamicColors.palette.m3surfaceContainerHigh;
			}
			implicitHeight: icon.implicitHeight + Appearance.padding.smaller * 2
			implicitWidth: implicitHeight
			radius: Appearance.rounding.normal

			MaterialIcon {
				id: icon

				anchors.centerIn: parent
				color: {
					if (root.modelData.type === Toast.Success)
						return DynamicColors.palette.m3onSuccess;
					if (root.modelData.type === Toast.Warning)
						return DynamicColors.palette.m3onSecondaryContainer;
					if (root.modelData.type === Toast.Error)
						return DynamicColors.palette.m3onError;
					return DynamicColors.palette.m3onSurfaceVariant;
				}
				font.pointSize: Math.round(Appearance.font.size.large * 1.2)
				text: root.modelData.icon
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			CustomText {
				id: title

				Layout.fillWidth: true
				color: {
					if (root.modelData.type === Toast.Success)
						return DynamicColors.palette.m3onSuccessContainer;
					if (root.modelData.type === Toast.Warning)
						return DynamicColors.palette.m3onSecondary;
					if (root.modelData.type === Toast.Error)
						return DynamicColors.palette.m3onErrorContainer;
					return DynamicColors.palette.m3onSurface;
				}
				elide: Text.ElideRight
				font.pointSize: Appearance.font.size.normal
				text: root.modelData.title
			}

			CustomText {
				Layout.fillWidth: true
				color: {
					if (root.modelData.type === Toast.Success)
						return DynamicColors.palette.m3onSuccessContainer;
					if (root.modelData.type === Toast.Warning)
						return DynamicColors.palette.m3onSecondary;
					if (root.modelData.type === Toast.Error)
						return DynamicColors.palette.m3onErrorContainer;
					return DynamicColors.palette.m3onSurface;
				}
				elide: Text.ElideRight
				opacity: 0.8
				text: root.modelData.message
				textFormat: Text.StyledText
			}
		}
	}
}
