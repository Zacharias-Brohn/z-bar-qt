pragma Singleton

import Quickshell
import Quickshell.Hyprland
import qs.Helpers

Singleton {
	function getInitialTitle(callback) {
		let activeWindow = Hypr.activeToplevel.title;
		let activeClass = Hypr.activeToplevel.lastIpcObject.class.toString();
		let regex = new RegExp(activeClass, "i");

		console.log("ActiveWindow", activeWindow, "ActiveClass", activeClass, "Regex", regex);

		const evalTitle = activeWindow.match(regex);
		callback(evalTitle);
	}
}
