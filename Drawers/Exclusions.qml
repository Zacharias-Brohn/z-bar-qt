pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.Config
import qs.Components

Scope {
	id: root

	required property Item bar
	required property ShellScreen screen

	ExclusionZone {
		anchors.top: true
		exclusiveZone: root.bar.exclusiveZone
	}

	ExclusionZone {
		anchors.left: true
	}

	ExclusionZone {
		anchors.right: true
	}

	ExclusionZone {
		anchors.bottom: true
	}

	component ExclusionZone: CustomWindow {
		exclusiveZone: Config.barConfig.border
		implicitHeight: 1
		implicitWidth: 1
		name: "Bar-Exclusion"
		screen: root.screen

		mask: Region {
		}
	}
}
