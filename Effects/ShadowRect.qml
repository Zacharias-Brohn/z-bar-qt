import QtQuick
import QtQuick.Effects

Item {
    id: root
    property real radius

    Rectangle {
        id: shadowRect
        anchors.fill: root
        radius: root.radius
        layer.enabled: true
        color: "black"
        visible: false
    }

    MultiEffect {
        id: effects
        source: shadowRect
        anchors.fill: shadowRect
        shadowBlur: 2.0
        shadowEnabled: true
        shadowOpacity: 1
        shadowColor: "black"
        maskSource: shadowRect
        maskEnabled: true
        maskInverted: true
        autoPaddingEnabled: true
    }
}
