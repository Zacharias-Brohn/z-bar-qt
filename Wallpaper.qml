import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Helpers
import qs.Modules

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            screen: modelData
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            Image {
                id: wallpaperImage
                anchors.fill: parent
                source: WallpaperPath.currentWallpaperPath
                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                retainWhileLoading: true

                // Behavior on source {
                //     Anim {
                //         properties: "opacity"
                //         duration: 500
                //     }
                // }
            }
        }
    }
}
