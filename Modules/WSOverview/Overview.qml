pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Config

Scope {
    id: overviewScope
    Variants {
        id: overviewVariants
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
            screen: modelData
            visible: false

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            mask: Region {
                item: keyHandler
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active)
                        root.visible = false;
                }
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight

            Item {
                id: keyHandler
                anchors.fill: parent
                visible: root.visible
                focus: root.visible

                Keys.onPressed: event => {
                    // close: Escape or Enter
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return) {
                        root.visible = false;
                        event.accepted = true;
                        return;
                    }

                    // Helper: compute current group bounds
                    const workspacesPerGroup = Config.overview.rows * Config.overview.columns;
                    const currentId = Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1;
                    const currentGroup = Math.floor((currentId - 1) / workspacesPerGroup);
                    const minWorkspaceId = currentGroup * workspacesPerGroup + 1;
                    const maxWorkspaceId = minWorkspaceId + workspacesPerGroup - 1;

                    let targetId = null;

                    // Arrow keys and vim-style hjkl
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                        targetId = currentId - 1;
                        if (targetId < minWorkspaceId) targetId = maxWorkspaceId;
                    } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                        targetId = currentId + 1;
                        if (targetId > maxWorkspaceId) targetId = minWorkspaceId;
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                        targetId = currentId - Config.overview.columns;
                        if (targetId < minWorkspaceId) targetId += workspacesPerGroup;
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                        targetId = currentId + Config.overview.columns;
                        if (targetId > maxWorkspaceId) targetId -= workspacesPerGroup;
                    }

                    // Number keys: jump to workspace within the current group
                    // 1-9 map to positions 1-9, 0 maps to position 10
                    else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                        const position = event.key - Qt.Key_0; // 1-9
                        if (position <= workspacesPerGroup) {
                            targetId = minWorkspaceId + position - 1;
                        }
                    } else if (event.key === Qt.Key_0) {
                        // 0 = 10th workspace in the group (if group has 10+ workspaces)
                        if (workspacesPerGroup >= 10) {
                            targetId = minWorkspaceId + 9; // 10th position = offset 9
                        }
                    }

                    if (targetId !== null) {
                        Hyprland.dispatch("workspace " + targetId);
                        event.accepted = true;
                    }
                }
            }

            ColumnLayout {
                id: columnLayout
                visible: root.visible
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 100
                }

                Loader {
                    id: overviewLoader
                    active: true && (Config.overview.enable ?? true)
                    sourceComponent: OverviewWidget {
                        panelWindow: root
                        visible: true
                    }
                }
            }
			IpcHandler {
				target: "overview"

				function toggle() {
					root.visible = !root.visible;
				}
				function close() {
					root.visible = false;
				}
				function open() {
					root.visible = true;
				}
			}
        }
    }
}
