import qs.Components
import qs.Config
import qs.Paths
import qs.Helpers
import qs.Modules
import Quickshell
import QtQuick

Row {
	id: root

	required property PersistentProperties state

	padding: 20
	spacing: 12

	CustomClippingRect {
		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		implicitHeight: info.implicitHeight
		implicitWidth: info.implicitHeight
		radius: 8

		MaterialIcon {
			anchors.centerIn: parent
			fill: 1
			font.pointSize: Math.floor(info.implicitHeight / 2) || 1
			grade: 200
			text: "person"
		}

		CachingImage {
			id: pfp

			anchors.fill: parent
			path: `${Paths.home}/.face`
		}
	}

	Column {
		id: info

		anchors.verticalCenter: parent.verticalCenter
		spacing: 12

		Item {
			id: line

			implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)
			implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin

			ColoredIcon {
				id: icon

				anchors.left: parent.left
				anchors.leftMargin: (Config.dashboard.sizes.infoIconSize - implicitWidth) / 2
				color: DynamicColors.palette.m3primary
				implicitSize: Math.floor(13 * 1.34)
				source: SystemInfo.osLogo
			}

			CustomText {
				id: text

				anchors.left: icon.right
				anchors.leftMargin: icon.anchors.leftMargin
				anchors.verticalCenter: icon.verticalCenter
				elide: Text.ElideRight
				font.pointSize: 13
				text: `:  ${SystemInfo.osPrettyName || SystemInfo.osName}`
				width: Config.dashboard.sizes.infoWidth
			}
		}

		InfoLine {
			colour: DynamicColors.palette.m3secondary
			icon: "select_window_2"
			text: SystemInfo.wm
		}

		InfoLine {
			id: uptime

			colour: DynamicColors.palette.m3tertiary
			icon: "timer"
			text: qsTr("%1").arg(SystemInfo.uptime)
		}
	}

	component InfoLine: Item {
		id: line

		required property color colour
		required property string icon
		required property string text

		implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)
		implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin

		MaterialIcon {
			id: icon

			anchors.left: parent.left
			anchors.leftMargin: (Config.dashboard.sizes.infoIconSize - implicitWidth) / 2
			color: line.colour
			fill: 1
			font.pointSize: 13
			text: line.icon
		}

		CustomText {
			id: text

			anchors.left: icon.right
			anchors.leftMargin: icon.anchors.leftMargin
			anchors.verticalCenter: icon.verticalCenter
			elide: Text.ElideNone
			font.pointSize: 13
			text: `:  ${line.text}`
			width: Config.dashboard.sizes.infoWidth
		}
	}
}
