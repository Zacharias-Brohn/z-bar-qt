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
	readonly property int maxHeight: {
		const otherModules = bar.children.filter(c => c.id && c.item !== this && c.id !== "spacer");
		const otherHeight = otherModules.reduce((acc, curr) => acc + (curr.item.nonAnimHeight ?? curr.height), 0);
		// Length - 2 cause repeater counts as a child
		return bar.height - otherHeight - bar.spacing * (bar.children.length - 1) - bar.vPadding * 2;
	}
	required property Brightness.Monitor monitor

	clip: true
	implicitHeight: current.implicitHeight
	implicitWidth: current.implicitWidth + current.anchors.leftMargin

	Behavior on implicitWidth {
		Anim {
			duration: MaterialEasing.expressiveEffectsTime
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	// MaterialIcon {
	//     id: icon
	//
	//     anchors.verticalCenter: parent.verticalCenter
	//
	//     animate: true
	//     text: Icons.getAppCategoryIcon(Hypr.activeToplevel?.lastIpcObject.class, "desktop_windows")
	//     color: root.colour
	// }

	Title {
		id: text1

	}

	Title {
		id: text2

	}

	TextMetrics {
		id: metrics

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
