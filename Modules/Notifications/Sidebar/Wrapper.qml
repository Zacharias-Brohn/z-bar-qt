pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import QtQuick

Item {
    id: root

    required property var visibilities
    required property var panels
    readonly property Props props: Props {}

    visible: width > 0
    implicitWidth: 0

    states: State {
        name: "visible"
        when: root.visibilities.sidebar

        PropertyChanges {
            root.implicitWidth: Config.sidebar.sizes.width
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitWidth"
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitWidth"
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }
    ]

    Loader {
        id: content

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 8
        anchors.bottomMargin: 0

        active: true
        Component.onCompleted: active = Qt.binding(() => (root.visibilities.sidebar && Config.sidebar.enabled) || root.visible)

        sourceComponent: Content {
            implicitWidth: Config.sidebar.sizes.width - 8 * 2
            props: root.props
            visibilities: root.visibilities
        }
    }
}
