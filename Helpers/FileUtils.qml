pragma Singleton
import Quickshell

Singleton {
	id: root

	function fileNameForPath(str) {
		if (typeof str !== "string")
			return "";
		const trimmed = trimFileProtocol(str);
		return trimmed.split(/[\\/]/).pop();
	}

	function trimFileExt(str) {
		if (typeof str !== "string")
			return "";
		const trimmed = trimFileProtocol(str);
		const lastDot = trimmed.lastIndexOf(".");
		if (lastDot > -1 && lastDot > trimmed.lastIndexOf("/")) {
			return trimmed.slice(0, lastDot);
		}
		return trimmed;
	}

	function trimFileProtocol(str) {
		return str.startsWith("file://") ? str.slice(7) : str;
	}
}
