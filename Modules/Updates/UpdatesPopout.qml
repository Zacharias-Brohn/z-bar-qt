pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Config
import qs.Components
import qs.Modules
import qs.Helpers

CustomClippingRect {
	id: root

	readonly property int itemHeight: 50 + Appearance.padding.smaller * 2
	required property var wrapper

	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: updatesList.visible ? updatesList.implicitHeight + Appearance.padding.small * 2 : noUpdates.height
	implicitWidth: updatesList.visible ? updatesList.contentWidth + Appearance.padding.small * 2 : noUpdates.width
	radius: Appearance.rounding.small

	Item {
		id: noUpdates

		anchors.centerIn: parent
		height: 200
		visible: script.values.length === 0
		width: 300

		MaterialIcon {
			id: noUpdatesIcon

			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: parent.top
			color: DynamicColors.tPalette.m3onSurfaceVariant
			font.pointSize: Appearance.font.size.extraLarge * 3
			horizontalAlignment: Text.AlignHCenter
			text: "check"
		}

		CustomText {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: noUpdatesIcon.bottom
			color: DynamicColors.tPalette.m3onSurfaceVariant
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("No updates available")
			verticalAlignment: Text.AlignVCenter
		}
	}

	CustomListView {
		id: updatesList

		anchors.centerIn: parent
		contentHeight: childrenRect.height
		contentWidth: 600
		implicitHeight: Math.min(contentHeight, (root.itemHeight + spacing) * 5 - spacing)
		implicitWidth: contentWidth
		spacing: Appearance.spacing.normal
		visible: script.values.length > 0

		delegate: CustomRect {
			id: update

			required property var modelData
			readonly property list<string> sections: modelData.update.split(" ")

			anchors.left: parent.left
			anchors.right: parent.right
			color: DynamicColors.tPalette.m3surfaceContainer
			implicitHeight: root.itemHeight
			radius: Appearance.rounding.small - Appearance.padding.small

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: Appearance.padding.smaller
				anchors.rightMargin: Appearance.padding.smaller

				MaterialIcon {
					font.pointSize: Appearance.font.size.large * 2
					text: "package_2"
				}

				ColumnLayout {
					Layout.fillWidth: true

					CustomText {
						Layout.fillWidth: true
						Layout.preferredHeight: 25
						elide: Text.ElideRight
						font.pointSize: Appearance.font.size.large
						text: update.sections[0]
					}

					CustomText {
						Layout.fillWidth: true
						color: DynamicColors.palette.m3onSurfaceVariant
						text: Updates.formatUpdateTime(update.modelData.timestamp)
					}
				}

				RowLayout {
					Layout.fillHeight: true
					Layout.preferredWidth: 300

					CustomText {
						id: versionFrom

						Layout.fillHeight: true
						Layout.preferredWidth: 125
						color: DynamicColors.palette.m3tertiary
						elide: Text.ElideRight
						font.pointSize: Appearance.font.size.large
						horizontalAlignment: Text.AlignHCenter
						text: update.sections[1]
						verticalAlignment: Text.AlignVCenter
					}

					MaterialIcon {
						Layout.fillHeight: true
						color: DynamicColors.palette.m3secondary
						font.pointSize: Appearance.font.size.extraLarge
						horizontalAlignment: Text.AlignHCenter
						text: "arrow_right_alt"
						verticalAlignment: Text.AlignVCenter
					}

					CustomText {
						id: versionTo

						Layout.fillHeight: true
						Layout.preferredWidth: 120
						color: DynamicColors.palette.m3primary
						elide: Text.ElideRight
						font.pointSize: Appearance.font.size.large
						horizontalAlignment: Text.AlignHCenter
						text: update.sections[3]
						verticalAlignment: Text.AlignVCenter
					}
				}
			}
		}
		model: ScriptModel {
			id: script

			objectProp: "update"
			values: Object.entries(Updates.updates).sort((a, b) => b[1] - a[1]).map(([update, timestamp]) => ({
						update,
						timestamp
					}))
		}
	}
}
