pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Config
import qs.Helpers
import qs.Modules.UPower
import qs.Modules.Network

RowLayout {
	id: root
	anchors.fill: parent

	readonly property int vPadding: 6
	required property Wrapper popouts
	required property PersistentProperties visibilities
	required property PanelWindow bar
	required property ShellScreen screen

	function checkPopout(x: real): void {
		const ch = childAt(x, 2) as WrappedLoader;

		if (!ch) {
			if ( !popouts.currentName.includes("traymenu") )
				popouts.hasCurrent = false;
			return;
		}

		if ( visibilities.sidebar || visibilities.dashboard )
			return;

		const id = ch.id;
		const top = ch.x;
		const item = ch.item;
		const itemWidth = item.implicitWidth;


		if (id === "audio" && Config.barConfig.popouts.audio) {
			popouts.currentName = "audio";
			popouts.currentCenter = Qt.binding( () => item.mapToItem(root, itemWidth / 2, 0 ).x );
			popouts.hasCurrent = true;
		} else if ( id === "resources" && Config.barConfig.popouts.resources ) {
			popouts.currentName = "resources";
			popouts.currentCenter = Qt.binding( () => item.mapToItem( root, itemWidth / 2, 0 ).x );
			popouts.hasCurrent = true;
		} else if ( id === "tray" && Config.barConfig.popouts.tray ) {
			const index = Math.floor((( x - top ) / item.implicitWidth ) * item.items.count );
			const trayItem = item.items.itemAt( index );
			if ( trayItem ) {
				// popouts.currentName = `traymenu${ index }`;
				// popouts.currentCenter = Qt.binding( () => trayItem.mapToItem( root, trayItem.implicitWidth / 2, 0 ).x );
				// popouts.hasCurrent = true;
			} else {
				// popouts.hasCurrent = false;
			}
		} else if ( id === "clock" && Config.barConfig.popouts.clock ) {
			// Calendar.displayYear = new Date().getFullYear();
			// Calendar.displayMonth = new Date().getMonth();
			// popouts.currentName = "calendar";
			// popouts.currentCenter = Qt.binding( () => item.mapToItem( root, itemWidth / 2, 0 ).x );
			// popouts.hasCurrent = true;
		} else if ( id === "network" && Config.barConfig.popouts.network ) {
			popouts.currentName = "network";
			popouts.currentCenter = Qt.binding( () => item.mapToItem( root, itemWidth / 2, 0 ).x );
			popouts.hasCurrent = true;
		} else if ( id === "upower" && Config.barConfig.popouts.upower ) {
			popouts.currentName = "upower";
			popouts.currentCenter = Qt.binding( () => item.mapToItem( root, itemWidth / 2, 0 ).x );
			popouts.hasCurrent = true;
		}
	}

	CustomShortcut {
		name: "toggle-overview"

		onPressed: {
			Hyprland.refreshWorkspaces();
			Hyprland.refreshMonitors();
			if ( root.popouts.hasCurrent && root.popouts.currentName === "overview" ) {
				root.popouts.hasCurrent = false;
			} else {
				root.popouts.currentName = "overview";
				root.popouts.currentCenter = root.width / 2;
				root.popouts.hasCurrent = true;
			}
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
						popouts: root.popouts
						loader: root
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
						visibilities: root.visibilities
						popouts: root.popouts
					}
				}
			}
			DelegateChoice {
				roleValue: "clock"
				delegate: WrappedLoader {
					sourceComponent: Clock {
						popouts: root.popouts
						visibilities: root.visibilities
						loader: root
					}
				}
			}
			DelegateChoice {
				roleValue: "activeWindow"
				delegate: WrappedLoader {
					sourceComponent: WindowTitle {
						bar: root
						monitor: Brightness.getMonitorForScreen(root.screen)
					}
				}
			}
			DelegateChoice {
				roleValue: "upower"
				delegate: WrappedLoader {
					sourceComponent: UPowerWidget {}
				}
			}
			DelegateChoice {
				roleValue: "network"
				delegate: WrappedLoader {
					sourceComponent: NetworkWidget {}
				}
			}
			// DelegateChoice {
			// 	roleValue: "dash"
			// 	delegate: WrappedLoader {
			// 		sourceComponent: DashWidget {
			// 			visibilities: root.visibilities
			// 		}
			// 	}
			// }
		}
	}

	component WrappedLoader: Loader {
		required property bool enabled
		required property string id
		required property int index

		Layout.alignment: Qt.AlignVCenter
		Layout.fillHeight: true

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

		Layout.leftMargin: findFirstEnabled() === this ? root.vPadding : 0
		Layout.rightMargin: findLastEnabled() === this ? root.vPadding : 0

		visible: enabled
		active: enabled
	}
}
