import Quickshell
import Quickshell.Widgets
import QtQuick

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
			source: `${Quickshell.shellDir}/images/.face`
			sourceSize.height: parent.height
			sourceSize.width: parent.width
		}
	}
}
