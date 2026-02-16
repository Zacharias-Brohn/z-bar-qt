import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

GridLayout {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Appearance.padding.large

    rowSpacing: Appearance.spacing.large
    columnSpacing: Appearance.spacing.large
    rows: 1
    columns: 2

    Ref {
        service: SystemUsage
    }

    Resource {
        Layout.bottomMargin: Appearance.padding.large
        Layout.topMargin: Appearance.padding.large
        icon: "memory"
        value: SystemUsage.cpuPerc
        colour: DynamicColors.palette.m3primary
    }

    Resource {
        Layout.bottomMargin: Appearance.padding.large
        Layout.topMargin: Appearance.padding.large
        icon: "memory_alt"
        value: SystemUsage.memPerc
        colour: DynamicColors.palette.m3secondary
    }

    component Resource: CustomRect {
        id: res

        required property string icon
        required property real value
        required property color colour

        Layout.fillWidth: true
        implicitHeight: width

        color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
        radius: Appearance.rounding.large

        CircularProgress {
            id: circ

            anchors.fill: parent
            value: res.value
            padding: Appearance.padding.large * 3
            fgColour: res.colour
            bgColour: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 3)
            strokeWidth: width < 200 ? Appearance.padding.smaller : Appearance.padding.normal
        }

        MaterialIcon {
            id: icon

            anchors.centerIn: parent
            text: res.icon
            color: res.colour
            font.pointSize: (circ.arcRadius * 0.7) || 1
            font.weight: 600
        }

        Behavior on value {
            Anim {
                duration: Appearance.anim.durations.large
            }
        }
    }
}
