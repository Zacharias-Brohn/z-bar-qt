import QtQuick
import Quickshell
import qs.Modules
import qs.Helpers
import qs.Config
import qs.Components
import qs.Paths
import ZShell.Services

Item {
	id: root

	property int cellHeight: 110
	property int cellWidth: 100
	property var contextMenu: desktopMenu
	property string dragLeader: ""
	property string editingFilePath: ""
	property real groupDragX: 0
	property real groupDragY: 0
	property bool lassoActive: false
	property var selectedIcons: []
	property real startX: 0
	property real startY: 0

	function exec(filePath, isDir) {
		const cmd = ["xdg-open", filePath];
		Quickshell.execDetached(cmd);
	}

	function performMassDrop(leaderPath, targetX, targetY) {
		let maxCol = Math.max(0, Math.floor(gridArea.width / cellWidth) - 1);
		let maxRow = Math.max(0, Math.floor(gridArea.height / cellHeight) - 1);

		let visuals = [];
		for (let i = 0; i < gridArea.children.length; i++) {
			let child = gridArea.children[i];
			if (child.filePath && root.selectedIcons.includes(child.filePath)) {
				let isLeader = (root.dragLeader === child.filePath);
				let offsetX = isLeader ? child.getDragX() : root.groupDragX;
				let offsetY = isLeader ? child.getDragY() : root.groupDragY;
				visuals.push({
					childRef: child,
					absX: child.x + offsetX,
					absY: child.y + offsetY
				});
			}
		}

		desktopModel.massMove(root.selectedIcons, leaderPath, targetX, targetY, maxCol, maxRow);

		for (let i = 0; i < visuals.length; i++) {
			visuals[i].childRef.compensateAndSnap(visuals[i].absX, visuals[i].absY);
		}

		root.dragLeader = "";
		root.groupDragX = 0;
		root.groupDragY = 0;
	}

	focus: true

	Keys.onPressed: event => {
		if (event.key === Qt.Key_F2 && selectedIcons.length > 0)
			editingFilePath = selectedIcons[0];
	}

	DesktopModel {
		id: desktopModel

		Component.onCompleted: loadDirectory(FileUtils.trimFileProtocol(Paths.desktop))
	}

	CustomRect {
		id: lasso

		function hideLasso() {
			fadeIn.stop();
			fadeOut.start();
			root.lassoActive = false;
		}

		function showLasso() {
			root.lassoActive = true;
			fadeOut.stop();
			visible = true;
			fadeIn.start();
		}

		border.color: DynamicColors.palette.m3primary
		border.width: 1
		color: DynamicColors.tPalette.m3primary
		opacity: 0
		radius: Appearance.rounding.small
		visible: false
		z: 99

		NumberAnimation {
			id: fadeIn

			duration: 120
			from: 0
			property: "opacity"
			target: lasso
			to: 1
		}

		SequentialAnimation {
			id: fadeOut

			NumberAnimation {
				duration: 120
				from: lasso.opacity
				property: "opacity"
				target: lasso
				to: 0
			}

			ScriptAction {
				script: lasso.visible = false
			}
		}
	}

	MouseArea {
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		anchors.fill: parent

		onPositionChanged: mouse => {
			if (lasso.visible) {
				lasso.x = Math.floor(Math.min(mouse.x, root.startX));
				lasso.y = Math.floor(Math.min(mouse.y, root.startY));
				lasso.width = Math.floor(Math.abs(mouse.x - root.startX));
				lasso.height = Math.floor(Math.abs(mouse.y - root.startY));

				let minCol = Math.floor((lasso.x - gridArea.x) / cellWidth);
				let maxCol = Math.floor((lasso.x + lasso.width - gridArea.x) / cellWidth);
				let minRow = Math.floor((lasso.y - gridArea.y) / cellHeight);
				let maxRow = Math.floor((lasso.y + lasso.height - gridArea.y) / cellHeight);

				let newSelection = [];
				for (let i = 0; i < gridArea.children.length; i++) {
					let child = gridArea.children[i];
					if (child.filePath !== undefined && child.gridX >= minCol && child.gridX <= maxCol && child.gridY >= minRow && child.gridY <= maxRow) {
						newSelection.push(child.filePath);
					}
				}
				root.selectedIcons = newSelection;
			}
		}
		onPressed: mouse => {
			root.editingFilePath = "";
			desktopMenu.close();

			if (mouse.button === Qt.RightButton) {
				root.selectedIcons = [];
				bgContextMenu.openAt(mouse.x, mouse.y, root.width, root.height);
			} else {
				bgContextMenu.close();
				root.selectedIcons = [];
				root.startX = Math.floor(mouse.x);
				root.startY = Math.floor(mouse.y);
				lasso.x = Math.floor(mouse.x);
				lasso.y = Math.floor(mouse.y);
				lasso.width = 0;
				lasso.height = 0;
				lasso.showLasso();
			}
		}
		onReleased: {
			lasso.hideLasso();
		}
	}

	Item {
		id: gridArea

		anchors.fill: parent
		anchors.margins: 20
		anchors.topMargin: 40
		visible: true

		Repeater {
			model: desktopModel

			delegate: DesktopIconDelegate {
				property int itemIndex: index

				lassoActive: root.lassoActive
			}
		}
	}

	DesktopIconContextMenu {
		id: desktopMenu

		onOpenFileRequested: (path, isDir) => root.exec(path, isDir)
		onRenameRequested: path => {
			root.editingFilePath = path;
		}
	}

	BackgroundContextMenu {
		id: bgContextMenu

	}
}
