import qs.Components
import qs.Config
import qs.Helpers
import QtQuick
import QtQuick.Layouts

CustomRect {
	id: root

	Layout.fillWidth: true
	clip: true
	color: DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: layout.implicitHeight + (IdleInhibitor.enabled ? activeChip.implicitHeight + activeChip.anchors.topMargin : 0) + 18 * 2
	radius: 8

	Behavior on implicitHeight {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	RowLayout {
		id: layout

		anchors.left: parent.left
		anchors.margins: 18
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: 10

		CustomRect {
			color: IdleInhibitor.enabled ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3secondaryContainer
			implicitHeight: icon.implicitHeight + 7 * 2
			implicitWidth: implicitHeight
			radius: 1000

			MaterialIcon {
				id: icon

				anchors.centerIn: parent
				color: IdleInhibitor.enabled ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSecondaryContainer
				font.pointSize: 18
				text: "coffee"
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			CustomText {
				Layout.fillWidth: true
				elide: Text.ElideRight
				font.pointSize: 13
				text: qsTr("Keep Awake")
			}

			CustomText {
				Layout.fillWidth: true
				color: DynamicColors.palette.m3onSurfaceVariant
				elide: Text.ElideRight
				font.pointSize: 11
				text: IdleInhibitor.enabled ? qsTr("Preventing sleep mode") : qsTr("Normal power management")
			}
		}

		CustomSwitch {
			checked: IdleInhibitor.enabled

			onToggled: IdleInhibitor.enabled = checked
		}
	}

	Loader {
		id: activeChip

		anchors.bottom: parent.bottom
		anchors.bottomMargin: IdleInhibitor.enabled ? 18 : -implicitHeight
		anchors.left: parent.left
		anchors.leftMargin: 18
		anchors.topMargin: 20
		opacity: IdleInhibitor.enabled ? 1 : 0
		scale: IdleInhibitor.enabled ? 1 : 0.5

		Behavior on anchors.bottomMargin {
			Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
			}
		}
		Behavior on opacity {
			Anim {
				duration: MaterialEasing.expressiveEffectsTime
			}
		}
		Behavior on scale {
			Anim {
			}
		}
		sourceComponent: CustomRect {
			color: DynamicColors.palette.m3primary
			implicitHeight: activeText.implicitHeight + 10 * 2
			implicitWidth: activeText.implicitWidth + 10 * 2
			radius: 1000

			CustomText {
				id: activeText

				anchors.centerIn: parent
				color: DynamicColors.palette.m3onPrimary
				font.pointSize: Math.round(11 * 0.9)
				text: qsTr("Active since %1").arg(Qt.formatTime(IdleInhibitor.enabledSince, Config.services.useTwelveHourClock ? "hh:mm a" : "hh:mm"))
			}
		}

		Component.onCompleted: active = Qt.binding(() => opacity > 0)
	}
}
