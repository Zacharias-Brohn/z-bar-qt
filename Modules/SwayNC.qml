import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth: notificationButton.implicitWidth
    implicitHeight: notificationButton.implicitHeight

    property var notificationState: ({})

    function updateState(output) {
        try {
            notificationState = JSON.parse(output.trim())
        } catch (e) {
            console.error("Failed to parse swaync state:", e)
        }
    }

    function getIcon() {
        let count = notificationState["text"] || 0
        let hasNotification = count > 0
        if (hasNotification) return "notification"
        return "none"
    }

    function getDisplayText() {
        let icon = getIcon()
        let count = notificationState["count"] || 0
        
        if (icon.includes("notification")) {
            return ""
        }
        return ""
    }

    Process {
        id: swayNcMonitor
        running: true
        command: ["swaync-client", "-swb"]
        
        stdout: SplitParser {
            onRead: data => root.updateState(data)
        }
    }

    Process {
        id: swayncProcess
        command: ["swaync-client", "-t", "-sw"]
        running: false
    }

    Button {
        id: notificationButton
        flat: true
        
        background: Rectangle {
            color: "transparent"
            radius: 4
        }
        
        contentItem: RowLayout {
            spacing: 0

            Text {
                text: root.getDisplayText()
                color: "white"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignVCenter
            }
            
            Text {
                text: "●"
                color: "red"
                font.pixelSize: 6
                visible: root.getIcon().includes("notification")
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                Layout.topMargin: 0
                Layout.rightMargin: 4
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                swayncProcess.running = true
            }
        }
    }
}
