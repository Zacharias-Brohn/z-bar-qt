pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules as Bar
import qs.Config
import qs.Helpers
import qs.Modules.UPower
import qs.Modules.Network

RowLayout {
	id: root

	required property Bar.Wrapper popouts
	required property ShellScreen screen
	readonly property int vPadding: 6
	required property PersistentProperties visibilities

	function checkPopout(x: real): void {
		const ch = childAt(x, 2) as WrappedLoader;

		if (!ch || ch?.id === "spacer") {
			if (!popouts.currentName.startsWith("traymenu"))
				popouts.hasCurrent = false;
			return;
		}

		if (visibilities.sidebar || visibilities.dashboard || visibilities.resources)
			return;

		const id = ch.id;
		const top = ch.x;
		const item = ch.item;
		const itemWidth = item.implicitWidth;

		if (id === "audio" && Config.barConfig.popouts.audio) {
			popouts.currentName = "audio";
			popouts.currentCenter = Qt.binding(() => item.mapToItem(root, itemWidth / 2, 0).x);
			popouts.hasCurrent = true;
		} else if (id === "network" && Config.barConfig.popouts.network) {
			popouts.currentName = "network";
			popouts.currentCenter = Qt.binding(() => item.mapToItem(root, itemWidth / 2, 0).x);
			popouts.hasCurrent = true;
		} else if (id === "upower" && Config.barConfig.popouts.upower) {
			popouts.currentName = "upower";
			popouts.currentCenter = Qt.binding(() => item.mapToItem(root, itemWidth / 2, 0).x);
			popouts.hasCurrent = true;
		}
	}

	spacing: Appearance.spacing.small

	Repeater {
		id: repeater

		// model: Config.barConfig.entries.filted(n => n.index > 50).sort(n => n.index)
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
					sourceComponent: Bar.Workspaces {
						screen: root.screen
					}
				}
			}

			DelegateChoice {
				roleValue: "audio"

				delegate: WrappedLoader {
					sourceComponent: Bar.AudioWidget {
					}
				}
			}

			DelegateChoice {
				roleValue: "tray"

				delegate: WrappedLoader {
					sourceComponent: Bar.TrayWidget {
						loader: root
						popouts: root.popouts
					}
				}
			}

			DelegateChoice {
				roleValue: "resources"

				delegate: WrappedLoader {
					sourceComponent: Bar.Resources {
						visibilities: root.visibilities
					}
				}
			}

			DelegateChoice {
				roleValue: "updates"

				delegate: WrappedLoader {
					sourceComponent: Bar.UpdatesWidget {
					}
				}
			}

			DelegateChoice {
				roleValue: "notifBell"

				delegate: WrappedLoader {
					sourceComponent: Bar.NotifBell {
						popouts: root.popouts
						visibilities: root.visibilities
					}
				}
			}

			DelegateChoice {
				roleValue: "clock"

				delegate: WrappedLoader {
					sourceComponent: Bar.Clock {
						loader: root
						popouts: root.popouts
						visibilities: root.visibilities
					}
				}
			}

			DelegateChoice {
				roleValue: "activeWindow"

				delegate: WrappedLoader {
					sourceComponent: Bar.WindowTitle {
						bar: root
					}
				}
			}

			DelegateChoice {
				roleValue: "upower"

				delegate: WrappedLoader {
					sourceComponent: UPowerWidget {
					}
				}
			}

			DelegateChoice {
				roleValue: "network"

				delegate: WrappedLoader {
					sourceComponent: NetworkWidget {
					}
				}
			}

			DelegateChoice {
				roleValue: "media"

				delegate: WrappedLoader {
					sourceComponent: Bar.MediaWidget {
					}
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

		Layout.alignment: Qt.AlignVCenter
		Layout.fillHeight: true
		Layout.leftMargin: findFirstEnabled() === this ? root.vPadding : 0
		Layout.rightMargin: findLastEnabled() === this ? root.vPadding : 0
		active: enabled
		visible: enabled
	}
}
