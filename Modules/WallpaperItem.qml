import Quickshell
import QtQuick
import Caelestia.Models

Item {
    id: root
    required property FileSystemEntry modelData
    implicitWidth: 192
    implicitHeight: 108

    Image {
        id: thumbnailImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.modelData.path
    }
}
