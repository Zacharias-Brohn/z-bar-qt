import QtQuick
import qs.Components
import qs.Config

Item {
    id: root

    required property var visibilities
    required property Item panels

    visible: height > 0
    implicitWidth: Math.max(panels.sidebar.width, content.implicitWidth)
    implicitHeight: content.implicitHeight

    states: State {
        name: "hidden"
        when: root.visibilities.sidebar

        PropertyChanges {
            root.implicitHeight: 0
        }
    }

    transitions: Transition {
        Anim {
            target: root
            property: "implicitHeight"
            duration: MaterialEasing.expressiveEffectsTime
            easing.bezierCurve: MaterialEasing.expressiveEffects
        }
    }

    Content {
        id: content

        visibilities: root.visibilities
        panels: root.panels
    }
}
