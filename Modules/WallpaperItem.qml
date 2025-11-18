import Quickshell
import Quickshell.Widgets
import QtQuick
import ZShell.Models

Item {
    id: root
    required property FileSystemEntry modelData
    implicitWidth: 288
    implicitHeight: 162

    scale: 0.5
    opacity: 0
    z: PathView.z ?? 0

    Component.onCompleted: {
        scale = Qt.binding(() => PathView.isCurrentItem ? 1 : PathView.onPath ? 0.8 : 0);
        opacity = Qt.binding(() => PathView.onPath ? 1 : 0);
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: 8
        color: "#10FFFFFF"
        Image {
            id: thumbnailImage

            asynchronous: true
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: root.modelData.path
            sourceSize.width: 960
            sourceSize.height: 540
        }
    }

    Behavior on scale {
        Anim {}
    }

    Behavior on opacity {
        Anim {}
    }
}
