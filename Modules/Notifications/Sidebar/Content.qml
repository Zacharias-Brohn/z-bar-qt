import qs.Components
import qs.Config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Props props
    required property var visibilities

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 8

        CustomRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 8
            color: DynamicColors.tPalette.m3surfaceContainerLow

            NotifDock {
                props: root.props
                visibilities: root.visibilities
            }
        }

        CustomRect {
            Layout.topMargin: 8 - layout.spacing
            Layout.fillWidth: true
            implicitHeight: 1

            color: DynamicColors.tPalette.m3outlineVariant
        }
    }
}
