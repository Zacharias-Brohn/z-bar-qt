import QtQuick
import qs.Config

BaseStyledSlider {
	id: root

	property real alpha: 1.0
	property real brightness: 1.0
	property string channel: "saturation"
	readonly property color currentColor: Qt.hsva(hue, channel === "saturation" ? value : saturation, channel === "brightness" ? value : brightness, alpha)
	property real hue: 0.0
	property real saturation: 1.0

	from: 0
	to: 1

	trackContent: Component {
		Item {
			property var groove
			property var handleItem
			property var rootSlider

			anchors.fill: parent

			Rectangle {
				anchors.fill: parent
				antialiasing: true
				color: "transparent"
				radius: groove?.radius ?? 0

				gradient: Gradient {
					orientation: rootSlider?.isHorizontal ? Gradient.Horizontal : Gradient.Vertical

					GradientStop {
						color: root.channel === "saturation" ? Qt.hsva(root.hue, 0.0, root.brightness, root.alpha) : Qt.hsva(root.hue, root.saturation, 0.0, root.alpha)
						position: 0.0
					}

					GradientStop {
						color: root.channel === "saturation" ? Qt.hsva(root.hue, 1.0, root.brightness, root.alpha) : Qt.hsva(root.hue, root.saturation, 1.0, root.alpha)
						position: 1.0
					}
				}
			}
		}
	}
}
