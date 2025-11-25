pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Config
import qs.Helpers
import qs.Daemons

RowLayout {
    id: root
    anchors.fill: parent
    anchors.leftMargin: 5
    anchors.rightMargin: 5

    readonly property int vPadding: 6
    required property Wrapper popouts
    required property PanelWindow bar

    function checkPopout(x: real): void {
        const ch = childAt(x, height / 2) as WrappedLoader;

        if (!ch) {
            popouts.hasCurrent = false;
            return;
        }

        const id = ch.id;
        const top = ch.x;
        const item = ch.item;
        const itemWidth = item.implicitWidth;


        if (id === "audio" && Config.barConfig.popouts.audio) {
            popouts.currentName = "audio";
            popouts.currentCenter = Qt.binding(() => item.mapToItem(root, itemWidth / 2, 0).x);
            popouts.hasCurrent = true;
        } else if ( id === "resources" && Config.barConfig.popouts.resources ) {
            popouts.currentName = "resources";
            popouts.currentCenter = Qt.binding(() => item.mapToItem(root, itemWidth / 2 + 5, 0).x);
            popouts.hasCurrent = true;
        } else if (id === "tray" && Config.barConfig.popouts.tray) {
            const index = Math.floor(((x - top - 6) / item.implicitWidth) * item.items.count);
            const trayItem = item.items.itemAt(index);
            if (trayItem) {
                popouts.currentName = `traymenu${index}`;
                popouts.currentCenter = Qt.binding(() => trayItem.mapToItem(root, trayItem.implicitWidth / 2 + 4, 0).x);
                popouts.hasCurrent = true;
            } else {
                popouts.hasCurrent = false;
            }
        } else if (id === "activeWindow" && Config.barConfig.popouts.activeWindow) {
            popouts.currentName = id.toLowerCase();
            popouts.currentCenter = item.mapToItem(root, 0, itemHeight / 2).y;
            popouts.hasCurrent = true;
        }
    }

    Repeater {
        id: repeater
        model: Config.barConfig.entries

        DelegateChooser {
            role: "id"

            DelegateChoice {
                roleValue: "spacer"
                delegate: WrappedLoader {
                    Layout.fillWidth: true
                }
            }
            DelegateChoice {
                roleValue: "workspaces"
                delegate: WrappedLoader {
                    sourceComponent: Workspaces {
                        bar: root.bar
                    }
                }
            }
            DelegateChoice {
                roleValue: "audio"
                delegate: WrappedLoader {
                    sourceComponent: AudioWidget {}
                }
            }
            DelegateChoice {
                roleValue: "tray"
                delegate: WrappedLoader {
                    sourceComponent: TrayWidget {
                        bar: root.bar
                    }
                }
            }
            DelegateChoice {
                roleValue: "resources"
                delegate: WrappedLoader {
                    sourceComponent: Resources {}
                }
            }
            DelegateChoice {
                roleValue: "updates"
                delegate: WrappedLoader {
                    sourceComponent: UpdatesWidget {}
                }
            }
            DelegateChoice {
                roleValue: "notifBell"
                delegate: WrappedLoader {
                    sourceComponent: NotifBell {
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            DelegateChoice {
                roleValue: "clock"
                delegate: WrappedLoader {
                    sourceComponent: Clock {
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            DelegateChoice {
                roleValue: "activeWindow"
                delegate: WrappedLoader {
                    sourceComponent: WindowTitle {}
                }
            }
        }
    }

    component WrappedLoader: Loader {
        required property bool enabled
        required property string id
        required property int index

        function findFirstEnabled(): Item {
            const count = repeater.count;
            for (let i = 0; i < count; i++) {
                const item = repeater.itemAt(i);
                if (item?.enabled)
                    return item;
            }
            return null;
        }

        function findLastEnabled(): Item {
            for (let i = repeater.count - 1; i >= 0; i--) {
                const item = repeater.itemAt(i);
                if (item?.enabled)
                    return item;
            }
            return null;
        }

        Layout.alignment: Qt.AlignHCenter

        // Cursed ahh thing to add padding to first and last enabled components
        Layout.topMargin: findFirstEnabled() === this ? root.vPadding : 0
        Layout.bottomMargin: findLastEnabled() === this ? root.vPadding : 0

        visible: enabled
        active: enabled
    }
}
