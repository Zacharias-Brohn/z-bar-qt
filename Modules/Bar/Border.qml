pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Effects
import qs.Modules
import qs.Config
import qs.Components

Item {
	id: root

	required property Item bar
	required property PersistentProperties visibilities

	anchors.fill: parent

	CustomRect {
		anchors.fill: parent
		color: Config.barConfig.border === 1 ? "transparent" : DynamicColors.palette.m3surface
		layer.enabled: true

		layer.effect: MultiEffect {
			maskEnabled: true
			maskInverted: true
			maskSource: mask
			maskSpreadAtMin: 1
			maskThresholdMin: 0.5
		}
	}

	Item {
		id: mask

		anchors.fill: parent
		layer.enabled: true
		visible: false

		Rectangle {
			anchors.fill: parent
			anchors.margins: Config.barConfig.border
			anchors.topMargin: root.bar.implicitHeight
			radius: Config.barConfig.border > 0 ? Config.barConfig.rounding : 0
			topLeftRadius: Config.barConfig.rounding
			topRightRadius: Config.barConfig.rounding
		}
	}
}
