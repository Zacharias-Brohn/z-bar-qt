import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Modules
import qs.Config
import qs.Components

Item {
    id: root
    implicitWidth: expanded ? 300 : 150
    implicitHeight: 34

    property bool expanded: false
    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3tertiaryFixed : "#ffffff"
    property color barColor: Config.useDynamicColors ? DynamicColors.palette.m3primary : "#ffffff"

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSource ]
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 22
        radius: height / 2
        color: Config.useDynamicColors ? DynamicColors.tPalette.m3surfaceContainer : "#40000000"

        Behavior on color {
            CAnim {}
        }

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

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: "volume_up"
                color: root.textColor
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 4
                radius: 20
                color: "#50ffffff"

                Rectangle {
                    id: sinkVolumeBar
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    implicitWidth: parent.width * ( Pipewire.defaultAudioSink?.audio.volume ?? 0 )
                    radius: parent.radius
                    color: root.barColor
                }
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 18
                text: Pipewire.defaultAudioSource?.audio.muted ? "mic_off" : "mic"
                color: ( Pipewire.defaultAudioSource?.audio.muted ?? false ) ? (Config.useDynamicColors ? DynamicColors.palette.m3onError : "#ff4444") : root.textColor
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 4
                radius: 20
                color: "#50ffffff"

                Rectangle {
                    id: sourceVolumeBar
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    implicitWidth: parent.width * ( Pipewire.defaultAudioSource?.audio.volume ?? 0 )
                    radius: parent.radius
                    color: ( Pipewire.defaultAudioSource?.audio.muted ?? false ) ? (Config.useDynamicColors ? DynamicColors.palette.m3onError : "#ff4444") : root.barColor

                    Behavior on color {
                        CAnim {}
                    }
                }
            }
        }
    }
}
