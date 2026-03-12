pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Config

Singleton {
	id: root

	property list<var> apps: {
		const pinnedApps = uniq((Config.dock.pinnedApps ?? []).map(normalizeId));
		const openMap = buildOpenMap();
		const openIds = [...openMap.keys()];
		const sessionOrder = uniq(root.unpinnedOrder.map(normalizeId));

		const orderedUnpinned = sessionOrder.filter(id => openIds.includes(id) && !pinnedApps.includes(id)).concat(openIds.filter(id => !pinnedApps.includes(id) && !sessionOrder.includes(id)));

		return [].concat(pinnedApps.map(appId => appEntryComp.createObject(null, {
				appId,
				pinned: true,
				toplevels: openMap.get(appId) ?? []
			}))).concat(pinnedApps.length > 0 ? [appEntryComp.createObject(null, {
				appId: root.separatorId,
				pinned: false,
				toplevels: []
			})] : []).concat(orderedUnpinned.map(appId => appEntryComp.createObject(null, {
				appId,
				pinned: false,
				toplevels: openMap.get(appId) ?? []
			})));
	}
	readonly property string separatorId: "__dock_separator__"
	property var unpinnedOrder: []

	function buildOpenMap() {
		const ignoredRegexes = (Config.dock.ignoredAppRegexes ?? []).map(pattern => new RegExp(pattern, "i"));

		return ToplevelManager.toplevels.values.reduce((map, toplevel) => {
			if (ignoredRegexes.some(re => re.test(toplevel.appId)))
				return map;

			const appId = normalizeId(toplevel.appId);
			if (!appId)
				return map;

			map.set(appId, (map.get(appId) ?? []).concat([toplevel]));
			return map;
		}, new Map());
	}

	function commitVisualOrder(ids) {
		const orderedIds = uniq(ids.map(normalizeId));
		const separatorIndex = orderedIds.indexOf(root.separatorId);

		const pinnedApps = (separatorIndex === -1 ? [] : orderedIds.slice(0, separatorIndex)).filter(id => id !== root.separatorId);

		const visibleUnpinned = orderedIds.slice(separatorIndex === -1 ? 0 : separatorIndex + 1).filter(id => id !== root.separatorId);

		Config.dock.pinnedApps = pinnedApps;
		root.unpinnedOrder = visibleUnpinned.concat(root.unpinnedOrder.map(normalizeId).filter(id => !pinnedApps.includes(id) && !visibleUnpinned.includes(id)));
		Config.saveNoToast();
	}

	function isPinned(appId) {
		return uniq((Config.dock.pinnedApps ?? []).map(normalizeId)).includes(normalizeId(appId));
	}

	function normalizeId(appId) {
		if (appId === root.separatorId)
			return root.separatorId;

		return String(appId ?? "").toLowerCase();
	}

	function togglePin(appId) {
		const id = normalizeId(appId);
		const pinnedApps = uniq((Config.dock.pinnedApps ?? []).map(normalizeId));
		const pinned = pinnedApps.includes(id);

		Config.dock.pinnedApps = pinned ? pinnedApps.filter(x => x !== id) : pinnedApps.concat([id]);

		root.unpinnedOrder = pinned ? [id].concat(root.unpinnedOrder.map(normalizeId).filter(x => x !== id)) : root.unpinnedOrder.map(normalizeId).filter(x => x !== id);
	}

	function uniq(ids) {
		return (ids ?? []).filter((id, i, arr) => id && arr.indexOf(id) === i);
	}

	Component {
		id: appEntryComp

		TaskbarAppEntry {
		}
	}

	component TaskbarAppEntry: QtObject {
		required property string appId
		required property bool pinned
		required property list<var> toplevels
	}
}
