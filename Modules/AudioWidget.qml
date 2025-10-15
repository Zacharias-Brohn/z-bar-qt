import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.Modules

Item {
    id: root
    implicitWidth: expanded ? 300 : 150
    implicitHeight: 100

    property bool expanded: false

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

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.expanded = true
            onExited: root.expanded = false
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
                        id: sinkVolumeBar
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }

                        implicitWidth: parent.width * ( Pipewire.defaultAudioSink?.audio.volume ?? 0 )
                        radius: parent.radius
                        color: "#ffffff"
                    }

                    Rectangle {
                        id: sinkGrabber
                        visible: root.expanded
                        opacity: root.expanded ? 1 : 0
                        width: sinkVolumeMouseArea.pressed ? 25 : 12
                        height: sinkVolumeMouseArea.pressed ? 25 : 12
                        radius: width / 2
                        color: sinkVolumeMouseArea.containsMouse || sinkVolumeMouseArea.pressed ? "#ffffff" : "#aaaaaa"
                        border.color: "#40000000"
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: sinkVolumeBar.width - width / 2

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: text.length === 3 ? -0.5 : 0
                            visible: sinkVolumeMouseArea.pressed
                            font.pixelSize: text.length === 3 ? 10 : 12
                            text: Math.round(( Pipewire.defaultAudioSink?.audio.volume ?? 0 ) * 100 ).toString()
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 50
                            }
                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 50
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: sinkVolumeMouseArea
                        anchors.fill: parent
                        anchors {
                            leftMargin: 0
                            rightMargin: 0
                            topMargin: -10
                            bottomMargin: -10
                        }
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onPressed: function( mouse ) {
                            var newVolume = Math.max( 0, Math.min( 1, mouse.x / width ))
                            if ( Pipewire.defaultAudioSink?.audio ) {
                                Pipewire.defaultAudioSink.audio.volume = newVolume
                            }
                        }

                        onPositionChanged: function( mouse ) {
                            if ( pressed ) {
                                var newVolume = Math.max( 0, Math.min( 1, mouse.x / width ))
                                if ( Pipewire.defaultAudioSink?.audio ) {
                                    Pipewire.defaultAudioSink.audio.volume = newVolume
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 18
                    text: "\ue029"
                    color: ( Pipewire.defaultAudioSource?.audio.muted ?? false ) ? "#ff4444" : "#ffffff"
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
                        color: ( Pipewire.defaultAudioSource?.audio.muted ?? false ) ? "#ff4444" : "#ffffff"
                    }

                    Rectangle {
                        id: sourceGrabber
                        visible: root.expanded
                        opacity: root.expanded ? 1 : 0
                        width: sourceVolumeMouseArea.pressed ? 25 : 12
                        height: sourceVolumeMouseArea.pressed ? 25 : 12
                        radius: width / 2
                        color: sourceVolumeMouseArea.containsMouse || sourceVolumeMouseArea.pressed ? "#ffffff" : "#aaaaaa"
                        border.color: "#40000000"
                        border.width: 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: sourceVolumeBar.width - width / 2

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: text.length === 3 ? -0.5 : 0
                            visible: sourceVolumeMouseArea.pressed
                            font.pixelSize: text.length === 3 ? 10 : 12
                            text: Math.round(( Pipewire.defaultAudioSource?.audio.volume ?? 0 ) * 100 ).toString()
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 50
                            }
                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 50
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: sourceVolumeMouseArea
                        anchors.fill: parent
                        anchors {
                            leftMargin: 0
                            rightMargin: 0
                            topMargin: -10
                            bottomMargin: -10
                        }
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onPressed: function( mouse ) {
                            var newVolume = Math.max( 0, Math.min( 1, mouse.x / width ))
                            if ( Pipewire.defaultAudioSource?.audio ) {
                                Pipewire.defaultAudioSource.audio.volume = newVolume
                            }
                        }

                        onPositionChanged: function( mouse ) {
                            if ( pressed ) {
                                var newVolume = Math.max( 0, Math.min( 1, mouse.x / width ))
                                if ( Pipewire.defaultAudioSource?.audio ) {
                                    Pipewire.defaultAudioSource.audio.volume = newVolume
                                }
                            }
                        }
                    }
                }
            }
        }

        Process {
            id: pavucontrolProc
            command: ["pavucontrol"]
            running: false
        }
    }
}
