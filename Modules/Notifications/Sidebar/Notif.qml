pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Daemons
import qs.Modules
import Quickshell
import QtQuick
import QtQuick.Layouts

CustomRect {
    id: root

    required property NotifServer.Notif modelData
    required property Props props
    required property bool expanded
    required property var visibilities

    readonly property CustomText body: expandedContent.item?.body ?? null
    readonly property real nonAnimHeight: expanded ? summary.implicitHeight + expandedContent.implicitHeight + expandedContent.anchors.topMargin + 10 * 2 : summaryHeightMetrics.height

    implicitHeight: nonAnimHeight

    radius: 6
    color: {
        const c = root.modelData.urgency === "critical" ? DynamicColors.palette.m3secondaryContainer : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2);
        return expanded ? c : Qt.alpha(c, 0);
    }

    states: State {
        name: "expanded"
        when: root.expanded

        PropertyChanges {
            summary.anchors.margins: 10
            dummySummary.anchors.margins: 10
            compactBody.anchors.margins: 10
            timeStr.anchors.margins: 10
            expandedContent.anchors.margins: 10
            summary.width: root.width - 10 * 2 - timeStr.implicitWidth - 7
            summary.maximumLineCount: Number.MAX_SAFE_INTEGER
        }
    }

    transitions: Transition {
        Anim {
            properties: "margins,width,maximumLineCount"
        }
    }

    TextMetrics {
        id: summaryHeightMetrics

        font: summary.font
        text: " " // Use this height to prevent weird characters from changing the line height
    }

    CustomText {
        id: summary

        anchors.top: parent.top
        anchors.left: parent.left

        width: parent.width
        text: root.modelData.summary
        color: root.modelData.urgency === "critical" ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        maximumLineCount: 1
    }

    CustomText {
        id: dummySummary

        anchors.top: parent.top
        anchors.left: parent.left

        visible: false
        text: root.modelData.summary
    }

    WrappedLoader {
        id: compactBody

        shouldBeActive: !root.expanded
        anchors.top: parent.top
        anchors.left: dummySummary.right
        anchors.right: parent.right
        anchors.leftMargin: 7

        sourceComponent: CustomText {
            text: root.modelData.body.replace(/\n/g, " ")
            color: root.modelData.urgency === "critical" ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3outline
            elide: Text.ElideRight
        }
    }

    WrappedLoader {
        id: timeStr

        shouldBeActive: root.expanded
        anchors.top: parent.top
        anchors.right: parent.right

        sourceComponent: CustomText {
            animate: true
            text: root.modelData.timeStr
            color: DynamicColors.palette.m3outline
            font.pointSize: 11
        }
    }

    WrappedLoader {
        id: expandedContent

        shouldBeActive: root.expanded
        anchors.top: summary.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 7 / 2

        sourceComponent: ColumnLayout {
            readonly property alias body: body

            spacing: 10

            CustomText {
                id: body

                Layout.fillWidth: true
                textFormat: Text.MarkdownText
                text: root.modelData.body.replace(/(.)\n(?!\n)/g, "$1\n\n") || qsTr("No body here! :/")
                color: root.modelData.urgency === "critical" ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3onSurface
                wrapMode: Text.WordWrap

                onLinkActivated: link => {
                    Quickshell.execDetached(["app2unit", "-O", "--", link]);
                    root.visibilities.sidebar = false;
                }
            }

            NotifActionList {
                notif: root.modelData
            }
        }
    }

    Behavior on implicitHeight {
        Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
        }
    }

    component WrappedLoader: Loader {
        required property bool shouldBeActive

        opacity: shouldBeActive ? 1 : 0
        active: opacity > 0

        Behavior on opacity {
            Anim {}
        }
    }
}
