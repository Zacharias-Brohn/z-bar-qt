pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules as Modules
import Quickshell
import QtQuick

Item {
    id: root

    required property var visibilities
    required property Item sidebar
    required property Item popouts

    readonly property PersistentProperties props: PersistentProperties {
        property bool recordingListExpanded: false
        property string recordingConfirmDelete
        property string recordingMode

        reloadableId: "utilities"
    }
    readonly property bool shouldBeActive: visibilities.sidebar

    visible: height > 0
    implicitHeight: 0
    implicitWidth: sidebar.visible ? sidebar.width : Config.utilities.sizes.width

    onStateChanged: {
        if (state === "visible" && timer.running) {
            timer.triggered();
            timer.stop();
        }
    }

    states: State {
        name: "visible"
        when: root.shouldBeActive

        PropertyChanges {
            root.implicitHeight: content.implicitHeight + 8 * 2
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Modules.Anim {
                target: root
                property: "implicitHeight"
				duration: MaterialEasing.expressiveEffectsTime
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        },
        Transition {
            from: "visible"
            to: ""

            Modules.Anim {
                target: root
                property: "implicitHeight"
				easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }
    ]

    Timer {
        id: timer

        running: true
        interval: 1000
        onTriggered: {
            content.active = Qt.binding(() => root.shouldBeActive || root.visible);
            content.visible = true;
        }
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 8

        visible: false
        active: true

        sourceComponent: Content {
            implicitWidth: root.implicitWidth - 8 * 2
            props: root.props
            visibilities: root.visibilities
            popouts: root.popouts
        }
    }
}
