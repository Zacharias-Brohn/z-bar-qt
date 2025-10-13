import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.Modules

Item {
    id: root
    implicitWidth: 150
    implicitHeight: 100

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSource ]
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#40000000"

        // Background circle
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: "transparent"
            border.color: "#30ffffff"
            border.width: 0
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 15
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue050"  // volume_up icon
                color: "#ffffff"
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 4
                radius: 20
                color: "#50ffffff"

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                    radius: parent.radius
                    color: "#ffffff"
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                font.family: "Material Symbols Rounded"
                font.pixelSize: 18
                text: "\ue029"
                color: (Pipewire.defaultAudioSource?.audio.muted ?? false) ? "#ff4444" : "#ffffff"
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 4
                radius: 20
                color: "#50ffffff"

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    implicitWidth: parent.width * (Pipewire.defaultAudioSource?.audio.volume ?? 0)
                    radius: parent.radius
                    color: (Pipewire.defaultAudioSource?.audio.muted ?? false) ? "#ff4444" : "#ffffff"
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: pavucontrolProc.running = true
        }
        Process {
            id: pavucontrolProc
            command: ["pavucontrol"]
            running: false
        }
    }
}
