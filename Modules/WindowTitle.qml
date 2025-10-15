import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root
    property string currentTitle
    Layout.fillHeight: true
    Layout.preferredWidth: Math.max( titleText1.implicitWidth, titleText2.implicitWidth ) + 10
    clip: true

    property bool showFirst: true

    Process {
        id: initialTitleProc
        command: ["./scripts/initialTitle.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let cleaned = this.text.trim().replace(/\"/g, "")
                root.currentTitle = ( cleaned === "null" ) ? "" : cleaned
            }
        }
    }

    Component.onCompleted: {
        Hyprland.rawEvent.connect(( event ) => {
            if (event.name === "activewindow") {
                initialTitleProc.running = true
            }
        })
    }

    onCurrentTitleChanged: {
        if (showFirst) {
            titleText2.text = currentTitle
            showFirst = false
        } else {
            titleText1.text = currentTitle
            showFirst = true
        }
    }

    Text {
        id: titleText1
        anchors.fill: parent
        anchors.margins: 5
        text: root.currentTitle
        color: "white"
        elide: Text.ElideRight
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: root.showFirst ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
    }

    Text {
        id: titleText2
        anchors.fill: parent
        anchors.margins: 5
        color: "white"
        elide: Text.ElideRight
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: root.showFirst ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
    }
}
