import QtQuick
import QtQuick.Layouts
import qs.Config

ColumnLayout {
	id: root

	default property alias content: contentColumn.data
	property string description: ""
	property bool expanded: false
	property bool nested: false
	property bool showBackground: false
	required property string title

	signal toggleRequested

	Layout.fillWidth: true
	spacing: Appearance.spacing.small

	Item {
		id: sectionHeaderItem

		Layout.fillWidth: true
		Layout.preferredHeight: Math.max(titleRow.implicitHeight + Appearance.padding.normal * 2, 48)

		RowLayout {
			id: titleRow

			anchors.left: parent.left
			anchors.leftMargin: Appearance.padding.normal
			anchors.right: parent.right
			anchors.rightMargin: Appearance.padding.normal
			anchors.verticalCenter: parent.verticalCenter
			spacing: Appearance.spacing.normal

			CustomText {
				font.pointSize: Appearance.font.size.larger
				font.weight: 500
				text: root.title
			}

			Item {
				Layout.fillWidth: true
			}

			MaterialIcon {
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.normal
				rotation: root.expanded ? 180 : 0
				text: "expand_more"

				Behavior on rotation {
					Anim {
						duration: Appearance.anim.durations.small
						easing.bezierCurve: Appearance.anim.curves.standard
					}
				}
			}
		}

		StateLayer {
			function onClicked(): void {
				root.toggleRequested();
				root.expanded = !root.expanded;
			}

			anchors.fill: parent
			color: DynamicColors.palette.m3onSurface
			radius: Appearance.rounding.normal
			showHoverBackground: false
		}
	}

	Item {
		id: contentWrapper

		Layout.fillWidth: true
		Layout.preferredHeight: root.expanded ? (contentColumn.implicitHeight + Appearance.spacing.small * 2) : 0
		clip: true

		Behavior on Layout.preferredHeight {
			Anim {
				easing.bezierCurve: Appearance.anim.curves.standard
			}
		}

		CustomRect {
			id: backgroundRect

			anchors.fill: parent
			color: DynamicColors.transparency.enabled ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, root.nested ? 3 : 2) : (root.nested ? DynamicColors.palette.m3surfaceContainerHigh : DynamicColors.palette.m3surfaceContainer)
			opacity: root.showBackground && root.expanded ? 1.0 : 0.0
			radius: Appearance.rounding.normal
			visible: root.showBackground

			Behavior on opacity {
				Anim {
					easing.bezierCurve: Appearance.anim.curves.standard
				}
			}
		}

		ColumnLayout {
			id: contentColumn

			anchors.bottomMargin: Appearance.spacing.small
			anchors.left: parent.left
			anchors.leftMargin: Appearance.padding.normal
			anchors.right: parent.right
			anchors.rightMargin: Appearance.padding.normal
			opacity: root.expanded ? 1.0 : 0.0
			spacing: Appearance.spacing.small
			y: Appearance.spacing.small

			Behavior on opacity {
				Anim {
					easing.bezierCurve: Appearance.anim.curves.standard
				}
			}

			CustomText {
				id: descriptionText

				Layout.bottomMargin: root.description !== "" ? Appearance.spacing.small : 0
				Layout.fillWidth: true
				Layout.topMargin: root.description !== "" ? Appearance.spacing.smaller : 0
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: Appearance.font.size.small
				text: root.description
				visible: root.description !== ""
				wrapMode: Text.Wrap
			}
		}
	}
}
