pragma ComponentBehavior: Bound

import ZShell
import Quickshell.Widgets
import QtQuick

IconImage {
	id: root

	required property color color

	asynchronous: true
	layer.enabled: true

	layer.effect: Coloriser {
		colorizationColor: root.color
		sourceColor: analyser.dominantColour
	}

	layer.onEnabledChanged: {
		if (layer.enabled && status === Image.Ready)
			analyser.requestUpdate();
	}
	onStatusChanged: {
		if (layer.enabled && status === Image.Ready)
			analyser.requestUpdate();
	}

	ImageAnalyser {
		id: analyser

		sourceItem: root
	}
}
