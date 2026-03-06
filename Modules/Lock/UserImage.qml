import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.Paths

Item {
	id: root

	ClippingRectangle {
		anchors.fill: parent
		radius: 1000

		Image {
			id: userImage

			anchors.fill: parent
			asynchronous: true
			fillMode: Image.PreserveAspectCrop
			source: `${Paths.home}/.face`
			sourceSize.height: parent.height
			sourceSize.width: parent.width
		}
	}
}
