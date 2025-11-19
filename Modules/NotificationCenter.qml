import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import QtQuick
import qs.Config
import qs.Helpers
import qs.Daemons
import qs.Effects

PanelWindow {
    id: root
    color: "transparent"
    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    required property PanelWindow bar
    property bool centerShown: false
    property alias posX: backgroundRect.x
    visible: false

    mask: Region { item: backgroundRect }

    IpcHandler {
        id: ipcHandler
        target: "root"

        function showCenter(): void { root.centerShown = !root.centerShown; }
    }

    onVisibleChanged: {
        if ( root.visible ) {
            showAnimation.start();
        }
    }

    onCenterShownChanged: {
        if ( !root.centerShown ) {
            closeAnimation.start();
            closeTimer.start();
        } else {
            root.visible = true;
        }
    }

    Keys.onPressed: {
        if ( event.key === Qt.Key_Escape ) {
            root.centerShown = false;
            event.accepted = true;
        }
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            root.visible = false;
        }
    }

    NumberAnimation {
        id: showAnimation
        target: backgroundRect
        property: "x"
        to: Math.round(root.bar.screen.width - backgroundRect.implicitWidth - 10)
        from: root.bar.screen.width
        duration: MaterialEasing.expressiveEffectsTime
        easing.bezierCurve: MaterialEasing.expressiveEffects
        onStopped: {
            focusGrab.active = true;
        }
    }

    NumberAnimation {
        id: closeAnimation
        target: backgroundRect
        property: "x"
        from: root.bar.screen.width - backgroundRect.implicitWidth - 10
        to: root.bar.screen.width
        duration: MaterialEasing.expressiveEffectsTime
        easing.bezierCurve: MaterialEasing.expressiveEffects
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: [ root ]
        onCleared: {
            root.centerShown = false;
        }
    }

    TrackedNotification {
        centerShown: root.centerShown
        bar: root.bar
    }

    ShadowRect {
        anchors.fill: backgroundRect
        radius: backgroundRect.radius
    }

    Rectangle {
        id: backgroundRect
        y: 10
        x: Screen.width
        z: 1
        implicitWidth: 400
        implicitHeight: root.height - 20
        color: Config.baseBgColor
        radius: 8
        border.color: "#555555"
        border.width: 1
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            NotificationCenterHeader { }

            Rectangle {
                color: "#333333"
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                pixelAligned: true
                contentHeight: notificationColumn.implicitHeight
                clip: true

                Column {
                    id: notificationColumn
                    width: parent.width
                    spacing: 10

                    add: Transition {
                        NumberAnimation {
                            properties: "x";
                            duration: 300;
                            easing.type: Easing.OutCubic
                        }
                    }

                    move: Transition {
                        NumberAnimation {
                            properties: "x";
                            duration: 200;
                            easing.type: Easing.OutCubic
                        }
                    }

                GroupListView { }

                }
            }
        }
    }
}
