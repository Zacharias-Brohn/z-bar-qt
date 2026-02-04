import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

CustomRect {
    id: root

    required property var visibilities
    required property Item popouts

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + 18 * 2

    radius: 8
    color: DynamicColors.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 7

            Toggle {
                icon: "notifications_off"
                checked: NotifServer.dnd
                onClicked: NotifServer.dnd = !NotifServer.dnd
            }
        }
    }

    component Toggle: IconButton {
        Layout.fillWidth: true
        Layout.preferredWidth: implicitWidth + (stateLayer.pressed ? 18 : internalChecked ? 7 : 0)
        radius: stateLayer.pressed ? 6 / 2 : internalChecked ? 6 : 8
        inactiveColour: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
        toggle: true
        radiusAnim.duration: MaterialEasing.expressiveEffectsTime
        radiusAnim.easing.bezierCurve: MaterialEasing.expressiveEffects

        Behavior on Layout.preferredWidth {
            Anim {
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }
    }
}
