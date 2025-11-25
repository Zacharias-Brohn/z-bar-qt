pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.Modules
import qs.Config
import qs.Components

Item {
    id: root

    required property Item bar

    anchors.fill: parent

    CustomRect {
        anchors.fill: parent
        color: DynamicColors.palette.m3surface

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
            anchors.topMargin: root.bar.implicitHeight
            topLeftRadius: 8
            topRightRadius: 8
        }
    }
}
