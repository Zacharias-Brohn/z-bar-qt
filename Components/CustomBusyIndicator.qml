import QtQuick
import QtQuick.Controls.Basic

BusyIndicator {
    id: control
	property color color: delegate.color
	property int busySize: 64

    contentItem: Item {
        implicitWidth: control.busySize
        implicitHeight: control.busySize

        Item {
            id: item
            x: parent.width / 2 - (control.busySize / 2)
            y: parent.height / 2 - (control.busySize / 2)
            width: control.busySize
            height: control.busySize
            opacity: control.running ? 1 : 0

            Behavior on opacity {
                OpacityAnimator {
                    duration: 250
                }
            }

            RotationAnimator {
                target: item
                running: control.visible && control.running
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1250
            }

            Repeater {
                id: repeater
                model: 6

                CustomRect {
                    id: delegate
                    x: item.width / 2 - width / 2
                    y: item.height / 2 - height / 2
                    implicitWidth: 10
                    implicitHeight: 10
                    radius: 5
                    color: control.color

                    required property int index

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
