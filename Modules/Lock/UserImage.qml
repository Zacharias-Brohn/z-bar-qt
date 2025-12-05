import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.Paths

Item {
	id: root

	ClippingRectangle {
		radius: 1000
		anchors.fill: parent
		Image {
			id: userImage

			anchors.fill: parent

			sourceSize.width: parent.width
			sourceSize.height: parent.height
			asynchronous: true
			fillMode: Image.PreserveAspectCrop
			source: `${Paths.home}/.face`
		}
	}
}
