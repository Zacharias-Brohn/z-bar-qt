import Quickshell
import QtQuick
import Quickshell.Wayland

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            screen: modelData
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            Image {
                id: wallpaperImage
                anchors.fill: parent
                source: "/mnt/IronWolf/SDImages/SWWW_Wals/ComfyUI_00037_.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
