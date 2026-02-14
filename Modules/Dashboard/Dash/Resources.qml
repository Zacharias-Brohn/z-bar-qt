import QtQuick
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules as Modules

Row {
    id: root

	anchors.top: parent.top
	anchors.bottom: parent.bottom

    padding: Appearance.padding.large
    spacing: Appearance.spacing.large

    Ref {
        service: SystemUsage
    }

    Resource {
        icon: "memory"
        value: SystemUsage.cpuPerc
        color: DynamicColors.palette.m3primary
    }

    Resource {
        icon: "memory_alt"
        value: SystemUsage.memPerc
        color: DynamicColors.palette.m3secondary
    }

    Resource {
        icon: "gamepad"
        value: SystemUsage.gpuPerc
        color: DynamicColors.palette.m3primaryFixed
    }

    Resource {
        icon: "host"
        value: SystemUsage.gpuMemUsed
        color: DynamicColors.palette.m3secondaryFixed
    }

    Resource {
        icon: "hard_disk"
        value: SystemUsage.storagePerc
        color: DynamicColors.palette.m3tertiary
    }

    component Resource: Item {
        id: res

        required property string icon
        required property real value
        required property color color

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Appearance.padding.large
        implicitWidth: icon.implicitWidth

        CustomRect {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: icon.top
            anchors.bottomMargin: Appearance.spacing.small

            implicitWidth: Config.dashboard.sizes.resourceProgessThickness

            color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
            radius: Appearance.rounding.full

            CustomRect {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                implicitHeight: res.value * parent.height

                color: res.color
                radius: Appearance.rounding.full
            }
        }

        MaterialIcon {
            id: icon

            anchors.bottom: parent.bottom

            text: res.icon
            color: res.color
        }

        Behavior on value {
            Modules.Anim {
                duration: Appearance.anim.durations.large
            }
        }
    }
}
