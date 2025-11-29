import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs.Config
import qs.Helpers

Item {
    id: root

    required property ShellScreen screen

    readonly property real nonAnimWidth: children.find(c => c.shouldBeActive)?.implicitWidth ?? content.implicitWidth
    readonly property real nonAnimHeight: hasCurrent ? children.find(c => c.shouldBeActive)?.implicitHeight ?? content.implicitHeight : 0
    readonly property Item current: content.item?.current ?? null

    property string currentName
    property real currentCenter
    property bool hasCurrent

    property string detachedMode
    property string queuedMode
    readonly property bool isDetached: detachedMode.length > 0

    property int animLength: MaterialEasing.emphasizedDecelTime
    property list<real> animCurve: MaterialEasing.emphasized

    function detach(mode: string): void {
        animLength = 600;
        if (mode === "winfo") {
            detachedMode = mode;
        } else {
            detachedMode = "any";
            queuedMode = mode;
        }
        focus = true;
    }

    function close(): void {
        hasCurrent = false;
        animCurve = MaterialEasing.emphasizedDecel;
        animLength = MaterialEasing.emphasizedDecelTime;
        detachedMode = "";
        animCurve = MaterialEasing.emphasized;
    }

    visible: width > 0 && height > 0
    clip: true

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    Keys.onEscapePressed: close()

    HyprlandFocusGrab {
        active: root.isDetached
        windows: [QsWindow.window]
        onCleared: root.close()
    }

    Binding {
        when: root.isDetached

        target: QsWindow.window
        property: "WlrLayershell.keyboardFocus"
        value: WlrKeyboardFocus.OnDemand
    }

    Comp {
        id: content

        shouldBeActive: root.hasCurrent
        asynchronous: true

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        sourceComponent: Content {
            wrapper: root
        }
    }

    // Comp {
    //     shouldBeActive: root.detachedMode === "winfo"
    //     asynchronous: true
    //     anchors.centerIn: parent
    //
    //     sourceComponent: WindowInfo {
    //         screen: root.screen
    //         client: Hypr.activeToplevel
    //     }
    // }

    // Comp {
    //     shouldBeActive: root.detachedMode === "any"
    //     asynchronous: true
    //     anchors.centerIn: parent
    //
    //     sourceComponent: ControlCenter {
    //         screen: root.screen
    //         active: root.queuedMode
    //
    //         function close(): void {
    //             root.close();
    //         }
    //     }
    // }

    Behavior on x {
        enabled: root.implicitHeight > 0
        Anim {
            duration: root.animLength
            easing.bezierCurve: root.animCurve
        }
    }

    Behavior on y {
        Anim {
            duration: root.animLength
            easing.bezierCurve: root.animCurve
        }
    }

    Behavior on implicitWidth {
        enabled: root.implicitHeight > 0
        Anim {
            duration: root.animLength
            easing.bezierCurve: root.animCurve
        }
    }

    Behavior on implicitHeight {
        Anim {
            duration: root.animLength
            easing.bezierCurve: root.animCurve
        }
    }

    component Comp: Loader {
        id: comp

        property bool shouldBeActive

        asynchronous: true
        active: false
        opacity: 0

        states: State {
            name: "active"
            when: comp.shouldBeActive

            PropertyChanges {
                comp.opacity: 1
                comp.active: true
            }
        }

        transitions: [
            Transition {
                from: ""
                to: "active"

                SequentialAnimation {
                    PropertyAction {
                        property: "active"
                    }
                    Anim {
                        property: "opacity"
                    }
                }
            },
            Transition {
                from: "active"
                to: ""

                SequentialAnimation {
                    Anim {
                        property: "opacity"
                    }
                    PropertyAction {
                        property: "active"
                    }
                }
            }
        ]
    }
}
