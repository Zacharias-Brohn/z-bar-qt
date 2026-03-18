pragma Singleton
import QtQuick

QtObject {
	id: root

	property Item activeMenu: null
	property Item activeTrigger: null

	function close(menu) {
		if (!menu)
			return;

		if (activeMenu === menu) {
			activeMenu = null;
			activeTrigger = null;
		}

		menu.expanded = false;
	}

	function closeActive() {
		if (activeMenu)
			activeMenu.expanded = false;

		activeMenu = null;
		activeTrigger = null;
	}

	function forget(menu) {
		if (activeMenu === menu) {
			activeMenu = null;
			activeTrigger = null;
		}
	}

	function hit(item, scenePos) {
		if (!item || !item.visible)
			return false;

		const p = item.mapFromItem(null, scenePos.x, scenePos.y);
		return item.contains(p);
	}

	function open(menu, trigger) {
		if (activeMenu && activeMenu !== menu)
			activeMenu.expanded = false;

		activeMenu = menu;
		activeTrigger = trigger || null;
		menu.expanded = true;
	}

	function toggle(menu, trigger) {
		if (activeMenu === menu && menu.expanded)
			close(menu);
		else
			open(menu, trigger);
	}
}
