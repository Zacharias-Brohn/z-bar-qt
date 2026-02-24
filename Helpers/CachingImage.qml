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
		function onDevicePixelRatioChanged(): void {
			manager.updateSource();
		}

		target: QsWindow.window
	}

	CachingImageManager {
		id: manager

		cacheDir: Qt.resolvedUrl(Paths.imagecache)
		item: root
	}
}
