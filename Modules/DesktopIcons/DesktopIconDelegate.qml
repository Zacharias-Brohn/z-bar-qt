import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Config
import qs.Components
import qs.Helpers

Item {
	id: delegateRoot

	property var appEntry: fileName.endsWith(".desktop") ? DesktopEntries.byId(DesktopUtils.getAppId(fileName)) : null
	property bool fileIsDir: model.isDir
	property string fileName: model.fileName
	property string filePath: model.filePath
	property int gridX: model.gridX
	property int gridY: model.gridY
	property bool isSnapping: snapAnimX.running || snapAnimY.running
	property bool lassoActive
	property string resolvedIcon: {
		if (fileName.endsWith(".desktop")) {
			if (appEntry && appEntry.icon && appEntry.icon !== "")
				return appEntry.icon;
			return AppSearch.guessIcon(DesktopUtils.getAppId(fileName));
		} else if (DesktopUtils.getFileType(fileName, fileIsDir) === "image") {
			return "file://" + filePath;
		} else {
			return DesktopUtils.getIconName(fileName, fileIsDir);
		}
	}

	function compensateAndSnap(absVisX, absVisY) {
		dragContainer.x = absVisX - delegateRoot.x;
		dragContainer.y = absVisY - delegateRoot.y;
		snapAnimX.start();
		snapAnimY.start();
	}

	function getDragX() {
		return dragContainer.x;
	}

	function getDragY() {
		return dragContainer.y;
	}

	height: root.cellHeight
	width: root.cellWidth
	x: gridX * root.cellWidth
	y: gridY * root.cellHeight

	Behavior on x {
		enabled: !mouseArea.drag.active && !isSnapping && !root.selectedIcons.includes(filePath)

		Anim {
		}
	}
	Behavior on y {
		enabled: !mouseArea.drag.active && !isSnapping && !root.selectedIcons.includes(filePath)

		Anim {
		}
	}

	Item {
		id: dragContainer

		height: parent.height
		width: parent.width

		states: State {
			when: mouseArea.drag.active

			PropertyChanges {
				opacity: 0.8
				scale: 1.1
				target: dragContainer
				z: 100
			}
		}
		transform: Translate {
			x: (root.selectedIcons.includes(filePath) && root.dragLeader !== "" && root.dragLeader !== filePath) ? root.groupDragX : 0
			y: (root.selectedIcons.includes(filePath) && root.dragLeader !== "" && root.dragLeader !== filePath) ? root.groupDragY : 0
		}
		transitions: Transition {
			Anim {
			}
		}

		onXChanged: {
			if (mouseArea.drag.active) {
				root.dragLeader = filePath;
				root.groupDragX = x;
			}
		}
		onYChanged: {
			if (mouseArea.drag.active) {
				root.dragLeader = filePath;
				root.groupDragY = y;
			}
		}

		PropertyAnimation {
			id: snapAnimX

			duration: 250
			easing.type: Easing.OutCubic
			property: "x"
			target: dragContainer
			to: 0
		}

		PropertyAnimation {
			id: snapAnimY

			duration: 250
			easing.type: Easing.OutCubic
			property: "y"
			target: dragContainer
			to: 0
		}

		Column {
			anchors.centerIn: parent
			spacing: 6

			IconImage {
				anchors.horizontalCenter: parent.horizontalCenter
				implicitSize: 48
				source: {
					if (delegateRoot.resolvedIcon.startsWith("file://") || delegateRoot.resolvedIcon.startsWith("/")) {
						return delegateRoot.resolvedIcon;
					} else {
						return Quickshell.iconPath(delegateRoot.resolvedIcon, fileIsDir ? "folder" : "text-x-generic");
					}
				}
			}

			Item {
				height: 40
				width: 88

				CustomText {
					anchors.fill: parent
					color: "white"
					elide: Text.ElideRight
					horizontalAlignment: Text.AlignHCenter
					maximumLineCount: 2
					style: Text.Outline
					styleColor: "black"
					text: (appEntry && appEntry.name !== "") ? appEntry.name : fileName
					visible: !renameLoader.active
					wrapMode: Text.Wrap
				}

				Loader {
					id: renameLoader

					active: root.editingFilePath === filePath
					anchors.centerIn: parent
					height: 24
					width: 110

					sourceComponent: CustomTextInput {
						anchors.fill: parent
						anchors.margins: 2
						color: "white"
						horizontalAlignment: Text.AlignHCenter
						text: fileName
						wrapMode: Text.Wrap

						Component.onCompleted: {
							forceActiveFocus();
							selectAll();
						}
						Keys.onPressed: function (event) {
							if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
								if (text.trim() !== "" && text !== fileName) {
									let newName = text.trim();
									let newPath = filePath.substring(0, filePath.lastIndexOf('/') + 1) + newName;

									Quickshell.execDetached(["mv", filePath, newPath]);
								}
								root.editingFilePath = "";
								event.accepted = true;
							} else if (event.key === Qt.Key_Escape) {
								root.editingFilePath = "";
								event.accepted = true;
							}
						}
						onActiveFocusChanged: {
							if (!activeFocus && root.editingFilePath === filePath) {
								root.editingFilePath = "";
							}
						}
					}
				}
			}
		}

		CustomRect {
			anchors.fill: parent
			anchors.margins: 4
			color: "white"
			opacity: root.selectedIcons.includes(filePath) ? 0.2 : 0.0
			radius: 8

			Behavior on opacity {
				Anim {
				}
			}
		}

		MouseArea {
			id: mouseArea

			acceptedButtons: Qt.LeftButton | Qt.RightButton
			anchors.fill: parent
			cursorShape: root.lassoActive ? undefined : Qt.PointingHandCursor
			drag.target: dragContainer
			hoverEnabled: true

			onClicked: mouse => {
				root.forceActiveFocus();

				if (mouse.button === Qt.RightButton) {
					if (!root.selectedIcons.includes(filePath)) {
						root.selectedIcons = [filePath];
					}
					let pos = mapToItem(root, mouse.x, mouse.y);
					root.contextMenu.openAt(pos.x, pos.y, filePath, fileIsDir, appEntry, root.width, root.height, root.selectedIcons);
				} else {
					root.selectedIcons = [filePath];
					root.contextMenu.close();
				}
			}
			onDoubleClicked: mouse => {
				if (mouse.button === Qt.LeftButton) {
					if (filePath.endsWith(".desktop") && appEntry)
						appEntry.execute();
					else
						root.exec(filePath, fileIsDir);
				}
			}
			onPressed: mouse => {
				if (mouse.button === Qt.LeftButton && !root.selectedIcons.includes(filePath)) {
					root.selectedIcons = [filePath];
				}
			}
			onReleased: {
				if (drag.active) {
					let absoluteX = delegateRoot.x + dragContainer.x;
					let absoluteY = delegateRoot.y + dragContainer.y;
					let snapX = Math.max(0, Math.round(absoluteX / root.cellWidth));
					let snapY = Math.max(0, Math.round(absoluteY / root.cellHeight));

					root.performMassDrop(filePath, snapX, snapY);
				}
			}

			CustomRect {
				anchors.fill: parent
				anchors.margins: 4
				color: "white"
				opacity: parent.containsMouse ? 0.1 : 0.0
				radius: 8

				Behavior on opacity {
					Anim {
					}
				}
			}
		}
	}
}
