import QtQuick
import QtQuick.Controls.Basic

BusyIndicator {
	id: control

	property int busySize: 64
	property color color: delegate.color

	contentItem: Item {
		implicitHeight: control.busySize
		implicitWidth: control.busySize

		Item {
			id: item

			height: control.busySize
			opacity: control.running ? 1 : 0
			width: control.busySize
			x: parent.width / 2 - (control.busySize / 2)
			y: parent.height / 2 - (control.busySize / 2)

			Behavior on opacity {
				OpacityAnimator {
					duration: 250
				}
			}

			RotationAnimator {
				duration: 1250
				from: 0
				loops: Animation.Infinite
				running: control.visible && control.running
				target: item
				to: 360
			}

			Repeater {
				id: repeater

				model: 6

				CustomRect {
					id: delegate

					required property int index

					color: control.color
					implicitHeight: 10
					implicitWidth: 10
					radius: 5
					x: item.width / 2 - width / 2
					y: item.height / 2 - height / 2

					transform: [
						Translate {
							y: -Math.min(item.width, item.height) * 0.5 + 5
						},
						Rotation {
							angle: delegate.index / repeater.count * 360
							origin.x: 5
							origin.y: 5
						}
					]
				}
			}
		}
	}
}
