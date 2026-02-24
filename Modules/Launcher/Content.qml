pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Modules.Launcher.Services
import qs.Components
import qs.Helpers
import qs.Config

Item {
	id: root

	required property real maxHeight
	readonly property int padding: Appearance.padding.small
	required property var panels
	readonly property int rounding: Appearance.rounding.large
	required property PersistentProperties visibilities

	implicitHeight: searchWrapper.height + listWrapper.height + padding * 2
	implicitWidth: listWrapper.width + padding * 2

	Item {
		id: listWrapper

		anchors.bottom: searchWrapper.top
		anchors.bottomMargin: root.padding
		anchors.horizontalCenter: parent.horizontalCenter
		implicitHeight: list.height + root.padding
		implicitWidth: list.width

		ContentList {
			id: list

			content: root
			maxHeight: root.maxHeight - searchWrapper.implicitHeight - root.padding * 3
			padding: root.padding
			panels: root.panels
			rounding: root.rounding
			search: search
			visibilities: root.visibilities
		}
	}

	CustomRect {
		id: searchWrapper

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.margins: root.padding
		anchors.right: parent.right
		color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)
		implicitHeight: Math.max(searchIcon.implicitHeight, search.implicitHeight, clearIcon.implicitHeight)
		radius: 8

		MaterialIcon {
			id: searchIcon

			anchors.left: parent.left
			anchors.leftMargin: root.padding + 10
			anchors.verticalCenter: parent.verticalCenter
			color: DynamicColors.palette.m3onSurfaceVariant
			text: "search"
		}

		CustomTextField {
			id: search

			anchors.left: searchIcon.right
			anchors.leftMargin: Appearance.spacing.small
			anchors.right: clearIcon.left
			anchors.rightMargin: Appearance.spacing.small
			bottomPadding: Appearance.padding.larger
			placeholderText: qsTr("Type \"%1\" for commands").arg(Config.launcher.actionPrefix)
			topPadding: Appearance.padding.larger

			Component.onCompleted: forceActiveFocus()
			Keys.onDownPressed: list.currentList?.decrementCurrentIndex()
			Keys.onEscapePressed: root.visibilities.launcher = false
			Keys.onPressed: event => {
				if (!Config.launcher.vimKeybinds)
					return;

				if (event.modifiers & Qt.ControlModifier) {
					if (event.key === Qt.Key_J) {
						list.currentList?.incrementCurrentIndex();
						event.accepted = true;
					} else if (event.key === Qt.Key_K) {
						list.currentList?.decrementCurrentIndex();
						event.accepted = true;
					}
				} else if (event.key === Qt.Key_Tab) {
					list.currentList?.incrementCurrentIndex();
					event.accepted = true;
				} else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
					list.currentList?.decrementCurrentIndex();
					event.accepted = true;
				}
			}
			Keys.onUpPressed: list.currentList?.incrementCurrentIndex()
			onAccepted: {
				const currentItem = list.currentList?.currentItem;
				if (currentItem) {
					if (list.showWallpapers) {
						if (DynamicColors.scheme === "dynamic" && currentItem.modelData.path !== Wallpapers.actualCurrent)
							Wallpapers.previewColourLock = true;
						Wallpapers.setWallpaper(currentItem.modelData.path);
						root.visibilities.launcher = false;
					} else if (text.startsWith(Config.launcher.actionPrefix)) {
						if (text.startsWith(`${Config.launcher.actionPrefix}calc `))
							currentItem.onClicked();
						else
							currentItem.modelData.onClicked(list.currentList);
					} else {
						Apps.launch(currentItem.modelData);
						root.visibilities.launcher = false;
					}
				}
			}

			Connections {
				function onLauncherChanged(): void {
					if (!root.visibilities.launcher)
						search.text = "";
				}

				function onSessionChanged(): void {
					if (!root.visibilities.session)
						search.forceActiveFocus();
				}

				target: root.visibilities
			}
		}

		MaterialIcon {
			id: clearIcon

			anchors.right: parent.right
			anchors.rightMargin: root.padding + 10
			anchors.verticalCenter: parent.verticalCenter
			color: DynamicColors.palette.m3onSurfaceVariant
			opacity: {
				if (!search.text)
					return 0;
				if (mouse.pressed)
					return 0.7;
				if (mouse.containsMouse)
					return 0.8;
				return 1;
			}
			text: "close"
			width: search.text ? implicitWidth : implicitWidth / 2

			Behavior on opacity {
				Anim {
					duration: Appearance.anim.durations.small
				}
			}
			Behavior on width {
				Anim {
					duration: Appearance.anim.durations.small
				}
			}

			MouseArea {
				id: mouse

				anchors.fill: parent
				cursorShape: search.text ? Qt.PointingHandCursor : undefined
				hoverEnabled: true

				onClicked: search.text = ""
			}
		}
	}
}
