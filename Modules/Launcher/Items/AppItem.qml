import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.Modules.Launcher.Services
import qs.Components
import qs.Helpers
import qs.Config
import qs.Modules

Item {
    id: root

    required property DesktopEntry modelData
    required property PersistentProperties visibilities

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: 8

        function onClicked(): void {
            Apps.launch(root.modelData);
            root.visibilities.launcher = false;
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        IconImage {
            id: icon

            source: Quickshell.iconPath(root.modelData?.icon, "image-missing")
            implicitSize: parent.height

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: icon.verticalCenter

            implicitWidth: parent.width - icon.width
            implicitHeight: name.implicitHeight + comment.implicitHeight

            CustomText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.normal
            }

            CustomText {
                id: comment

                text: (root.modelData?.comment || root.modelData?.genericName || root.modelData?.name) ?? ""
                font.pointSize: Appearance.font.size.small
                color: DynamicColors.palette.m3outline

                elide: Text.ElideRight
                width: root.width - icon.width - Appearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
