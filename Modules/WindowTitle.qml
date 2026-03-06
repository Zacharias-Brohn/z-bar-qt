pragma ComponentBehavior: Bound

import QtQuick
import qs.Components
import qs.Config
import qs.Helpers

Item {
	id: root

	required property var bar
	property color colour: DynamicColors.palette.m3primary
	property Title current: text1
	// readonly property int maxWidth: 300
	readonly property int maxWidth: {
		const otherModules = bar.children.filter(c => c.enabled && c.id && c.item !== this && c.id !== "spacer");
		const otherWidth = otherModules.reduce((acc, curr) => {
			return acc + (curr.item?.nonAnimWidth ?? curr.width ?? 0);
		}, 0);
		return bar.width - otherWidth - bar.spacing * (bar.children.length - 1) - bar.vPadding * 2;
	}
	required property Brightness.Monitor monitor

	clip: true
	implicitHeight: current.implicitHeight
	implicitWidth: Math.min(current.implicitWidth, root.maxWidth)

	Behavior on implicitWidth {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	Title {
		id: text1

	}

	Title {
		id: text2

	}

	TextMetrics {
		id: metrics

		elide: Qt.ElideRight
		elideWidth: root.maxWidth
		font.family: "Rubik"
		font.pointSize: 12
		text: Hypr.activeToplevel?.title ?? qsTr("Desktop")

		onElideWidthChanged: root.current.text = elidedText
		onTextChanged: {
			const next = root.current === text1 ? text2 : text1;
			next.text = elidedText;
			root.current = next;
		}
	}

	component Title: CustomText {
		id: text

		anchors.leftMargin: 7
		anchors.verticalCenter: parent.verticalCenter
		color: root.colour
		font.family: metrics.font.family
		font.pointSize: metrics.font.pointSize
		height: implicitHeight
		opacity: root.current === this ? 1 : 0
		width: implicitWidth

		Behavior on opacity {
			Anim {
			}
		}
	}
}
