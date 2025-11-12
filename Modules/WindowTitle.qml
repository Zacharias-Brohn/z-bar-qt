import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Helpers

Item {
    id: root
    property string currentTitle
    Layout.fillHeight: true
    Layout.preferredWidth: Math.max( titleText1.implicitWidth, titleText2.implicitWidth ) + 10
    clip: true

    property bool showFirst: true

    Component.onCompleted: {
        Hyprland.rawEvent.connect(( event ) => {
            if (event.name === "activewindow") {
                InitialTitle.getInitialTitle( function( initialTitle ) {
                    root.currentTitle = initialTitle
                })
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
