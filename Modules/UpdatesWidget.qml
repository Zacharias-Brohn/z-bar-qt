import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Config

Item {
	id: root

	property int countUpdates: Updates.availableUpdates
	property color textColor: DynamicColors.palette.m3onSurface

	anchors.bottom: parent.bottom
	anchors.top: parent.top
	implicitWidth: textMetrics.width + contentRow.spacing + 30

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		color: DynamicColors.tPalette.m3surfaceContainer
		implicitHeight: 22
		radius: height / 2

		Behavior on color {
			CAnim {
			}
		}
	}

	RowLayout {
		id: contentRow

		spacing: 10

		anchors {
			fill: parent
			leftMargin: 5
			rightMargin: 5
		}

		Text {
			Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
			color: root.textColor
			font.family: "Material Symbols Rounded"
			font.pixelSize: 18
			text: "\uf569"

			Behavior on color {
				CAnim {
				}
			}
		}

		TextMetrics {
			id: textMetrics

			font.pixelSize: 16
			text: root.countUpdates
		}

		Text {
			Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
			color: root.textColor
			text: textMetrics.text

			Behavior on color {
				CAnim {
				}
			}
		}
	}
}
