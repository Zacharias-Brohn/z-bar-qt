pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Config

ComboBox {
	id: root

	property int cornerRadius: Appearance.rounding.normal
	property int fieldHeight: 42
	property bool filled: true
	property real focusRingOpacity: 0.70
	property int hPadding: 16
	property int menuCornerRadius: 16
	property int menuRowHeight: 46
	property int menuVisibleRows: 7
	property bool preferPopupWindow: false

	hoverEnabled: true
	implicitHeight: fieldHeight
	implicitWidth: 240
	spacing: 8

	// ---------- Field background (filled/outlined + state layers + focus ring) ----------
	background: Item {
		anchors.fill: parent

		CustomRect {
			id: container

			anchors.fill: parent
			color: DynamicColors.palette.m3surfaceVariant
			radius: root.cornerRadius

			StateLayer {
			}
		}
	}

	// ---------- Content ----------
	contentItem: RowLayout {
		anchors.fill: parent
		anchors.leftMargin: root.hPadding
		anchors.rightMargin: root.hPadding
		spacing: 12

		// Display text
		CustomText {
			Layout.fillWidth: true
			color: root.enabled ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSurfaceVariant
			elide: Text.ElideRight
			font.pixelSize: 16
			font.weight: Font.Medium
			text: root.currentText
			verticalAlignment: Text.AlignVCenter
		}

		// Indicator chevron (simple, replace with your icon system)
		CustomText {
			color: root.enabled ? DynamicColors.palette.m3onSurfaceVariant : DynamicColors.palette.m3onSurfaceVariant
			rotation: root.popup.visible ? 180 : 0
			text: "▾"
			transformOrigin: Item.Center
			verticalAlignment: Text.AlignVCenter

			Behavior on rotation {
				NumberAnimation {
					duration: 140
					easing.type: Easing.OutCubic
				}
			}
		}
	}
	popup: Popup {
		id: p

		implicitHeight: list.contentItem.height + Appearance.padding.small * 2
		implicitWidth: root.width
		modal: true
		popupType: root.preferPopupWindow ? Popup.Window : Popup.Item
		y: -list.currentIndex * (root.menuRowHeight + Appearance.spacing.small) - Appearance.padding.small

		background: CustomRect {
			color: DynamicColors.palette.m3surface
			radius: root.menuCornerRadius
		}
		contentItem: ListView {
			id: list

			anchors.bottomMargin: Appearance.padding.small
			anchors.fill: parent
			anchors.topMargin: Appearance.padding.small
			clip: true
			currentIndex: root.currentIndex
			model: root.delegateModel
			spacing: Appearance.spacing.small

			delegate: CustomRect {
				required property int index
				required property var modelData

				anchors.horizontalCenter: parent.horizontalCenter
				color: (index === root.currentIndex) ? DynamicColors.palette.m3primary : "transparent"
				implicitHeight: root.menuRowHeight
				implicitWidth: p.implicitWidth - Appearance.padding.small * 2
				radius: Appearance.rounding.normal - Appearance.padding.small

				RowLayout {
					anchors.fill: parent
					spacing: 10

					CustomText {
						Layout.fillWidth: true
						color: DynamicColors.palette.m3onSurface
						elide: Text.ElideRight
						font.pixelSize: 15
						text: modelData
						verticalAlignment: Text.AlignVCenter
					}

					CustomText {
						color: DynamicColors.palette.m3onSurfaceVariant
						text: "✓"
						verticalAlignment: Text.AlignVCenter
						visible: index === root.currentIndex
					}
				}

				StateLayer {
					onClicked: {
						root.currentIndex = index;
						p.close();
					}
				}
			}
		}

		// Expressive-ish open/close motion: subtle scale+fade (tune to taste). :contentReference[oaicite:5]{index=5}
		enter: Transition {
			Anim {
				from: 0
				property: "opacity"
				to: 1
			}

			Anim {
				from: 0.98
				property: "scale"
				to: 1.0
			}
		}
		exit: Transition {
			Anim {
				from: 1
				property: "opacity"
				to: 0
			}
		}

		Elevation {
			anchors.fill: parent
			level: 2
			radius: root.menuCornerRadius
			z: -1
		}
	}
}
