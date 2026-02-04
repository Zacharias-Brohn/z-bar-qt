import qs.Components
import qs.Config
import qs.Modules as Modules
import qs.Helpers
import QtQuick
import QtQuick.Layouts

CustomRect {
    id: root

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + (IdleInhibitor.enabled ? activeChip.implicitHeight + activeChip.anchors.topMargin : 0) + 18 * 2

    radius: 8
    color: DynamicColors.tPalette.m3surfaceContainer
    clip: true

    RowLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 18
        spacing: 10

        CustomRect {
            implicitWidth: implicitHeight
            implicitHeight: icon.implicitHeight + 7 * 2

            radius: 1000
            color: IdleInhibitor.enabled ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3secondaryContainer

            MaterialIcon {
                id: icon

                anchors.centerIn: parent
                text: "coffee"
                color: IdleInhibitor.enabled ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSecondaryContainer
                font.pointSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            CustomText {
                Layout.fillWidth: true
                text: qsTr("Keep Awake")
                font.pointSize: 13
                elide: Text.ElideRight
            }

            CustomText {
                Layout.fillWidth: true
                text: IdleInhibitor.enabled ? qsTr("Preventing sleep mode") : qsTr("Normal power management")
                color: DynamicColors.palette.m3onSurfaceVariant
                font.pointSize: 11
                elide: Text.ElideRight
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
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.bottomMargin: IdleInhibitor.enabled ? 18 : -implicitHeight
        anchors.leftMargin: 18

        opacity: IdleInhibitor.enabled ? 1 : 0
        scale: IdleInhibitor.enabled ? 1 : 0.5

        Component.onCompleted: active = Qt.binding(() => opacity > 0)

        sourceComponent: CustomRect {
            implicitWidth: activeText.implicitWidth + 10 * 2
            implicitHeight: activeText.implicitHeight + 10 * 2

            radius: 1000
            color: DynamicColors.palette.m3primary

            CustomText {
                id: activeText

                anchors.centerIn: parent
                text: qsTr("Active since %1").arg(Qt.formatTime(IdleInhibitor.enabledSince, Config.services.useTwelveHourClock ? "hh:mm a" : "hh:mm"))
                color: DynamicColors.palette.m3onPrimary
                font.pointSize: Math.round(11 * 0.9)
            }
        }

        Behavior on anchors.bottomMargin {
            Modules.Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        Behavior on opacity {
            Modules.Anim {
				duration: MaterialEasing.expressiveEffectsTime
            }
        }

        Behavior on scale {
            Modules.Anim {}
        }
    }

    Behavior on implicitHeight {
        Modules.Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
        }
    }
}
