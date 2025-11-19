import ZShell.Internal
import Quickshell
import QtQuick
import qs.Paths

Image {
    id: root

    property alias path: manager.path

    asynchronous: true
    fillMode: Image.PreserveAspectCrop

    Connections {
        target: QsWindow.window

        function onDevicePixelRatioChanged(): void {
            manager.updateSource();
        }
    }

    CachingImageManager {
        id: manager

        item: root
        cacheDir: Qt.resolvedUrl(Paths.imagecache)
    }
}
