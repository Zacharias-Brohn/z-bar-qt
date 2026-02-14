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
        color: Config.autoHide && !root.visibilities.bar ? "transparent" : DynamicColors.palette.m3surface

        layer.enabled: true

        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: Config.autoHide && !root.visibilities.bar ? 4 : root.bar.implicitHeight
            topLeftRadius: 8
            topRightRadius: 8
			Behavior on anchors.topMargin {
				Anim {}
			}
        }
    }
}
