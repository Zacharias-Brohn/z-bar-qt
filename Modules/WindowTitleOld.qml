import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Helpers
import qs.Config
import qs.Components

Item {
    id: root
    property string currentTitle: Hypr.activeName
    Layout.fillHeight: true
    Layout.preferredWidth: Math.max( titleText1.implicitWidth, titleText2.implicitWidth ) + 10
    clip: true

    property bool showFirst: true
    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3primary : "white"

    // Component.onCompleted: {
    //     Hyprland.rawEvent.connect(( event ) => {
    //         if (event.name === "activewindow") {
    //             InitialTitle.getInitialTitle( function( initialTitle ) {
    //                 root.currentTitle = initialTitle
    //             })
    //         }
    //     })
    // }

    onCurrentTitleChanged: {
        if (showFirst) {
            titleText2.text = currentTitle
            showFirst = false
        } else {
            titleText1.text = currentTitle
            showFirst = true
        }
    }

    CustomText {
        id: titleText1
        anchors.fill: parent
        anchors.margins: 5
        text: root.currentTitle
        color: root.textColor
        elide: Text.ElideRight
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: root.showFirst ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
    }

    CustomText {
        id: titleText2
        anchors.fill: parent
        anchors.margins: 5
        color: root.textColor
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
