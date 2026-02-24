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

	readonly property CustomText body: expandedContent.item?.body ?? null
	required property bool expanded
	required property NotifServer.Notif modelData
	readonly property real nonAnimHeight: expanded ? summary.implicitHeight + expandedContent.implicitHeight + expandedContent.anchors.topMargin + 10 * 2 : summaryHeightMetrics.height
	required property Props props
	required property var visibilities

	color: {
		const c = root.modelData.urgency === "critical" ? DynamicColors.palette.m3secondaryContainer : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2);
		return expanded ? c : Qt.alpha(c, 0);
	}
	implicitHeight: nonAnimHeight
	radius: 6

	Behavior on implicitHeight {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}
	states: State {
		name: "expanded"
		when: root.expanded

		PropertyChanges {
			compactBody.anchors.margins: 10
			dummySummary.anchors.margins: 10
			expandedContent.anchors.margins: 10
			summary.anchors.margins: 10
			summary.maximumLineCount: Number.MAX_SAFE_INTEGER
			summary.width: root.width - 10 * 2 - timeStr.implicitWidth - 7
			timeStr.anchors.margins: 10
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

		anchors.left: parent.left
		anchors.top: parent.top
		color: root.modelData.urgency === "critical" ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
		elide: Text.ElideRight
		maximumLineCount: 1
		text: root.modelData.summary
		width: parent.width
		wrapMode: Text.WordWrap
	}

	CustomText {
		id: dummySummary

		anchors.left: parent.left
		anchors.top: parent.top
		text: root.modelData.summary
		visible: false
	}

	WrappedLoader {
		id: compactBody

		anchors.left: dummySummary.right
		anchors.leftMargin: 7
		anchors.right: parent.right
		anchors.top: parent.top
		shouldBeActive: !root.expanded

		sourceComponent: CustomText {
			color: root.modelData.urgency === "critical" ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3outline
			elide: Text.ElideRight
			text: root.modelData.body.replace(/\n/g, " ")
			textFormat: Text.StyledText
		}
	}

	WrappedLoader {
		id: timeStr

		anchors.right: parent.right
		anchors.top: parent.top
		shouldBeActive: root.expanded

		sourceComponent: CustomText {
			animate: true
			color: DynamicColors.palette.m3outline
			font.pointSize: 11
			text: root.modelData.timeStr
		}
	}

	WrappedLoader {
		id: expandedContent

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: summary.bottom
		anchors.topMargin: 7 / 2
		shouldBeActive: root.expanded

		sourceComponent: ColumnLayout {
			readonly property alias body: body

			spacing: 10

			CustomText {
				id: body

				Layout.fillWidth: true
				color: root.modelData.urgency === "critical" ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3onSurface
				text: root.modelData.body.replace(/(.)\n(?!\n)/g, "$1\n\n") || qsTr("No body given")
				textFormat: Text.MarkdownText
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

	component WrappedLoader: Loader {
		required property bool shouldBeActive

		active: opacity > 0
		opacity: shouldBeActive ? 1 : 0

		Behavior on opacity {
			Anim {
			}
		}
	}
}
