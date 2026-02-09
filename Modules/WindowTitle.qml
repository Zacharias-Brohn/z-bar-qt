pragma ComponentBehavior: Bound

import QtQuick
import qs.Components
import qs.Config
import qs.Helpers

Item {
    id: root

    required property var bar
    required property Brightness.Monitor monitor
    property color colour: DynamicColors.palette.m3primary

    readonly property int maxHeight: {
        const otherModules = bar.children.filter(c => c.id && c.item !== this && c.id !== "spacer");
        const otherHeight = otherModules.reduce((acc, curr) => acc + (curr.item.nonAnimHeight ?? curr.height), 0);
        // Length - 2 cause repeater counts as a child
        return bar.height - otherHeight - bar.spacing * (bar.children.length - 1) - bar.vPadding * 2;
    }
    property Title current: text1

    clip: true
    implicitWidth: current.implicitWidth + current.anchors.leftMargin
    implicitHeight: current.implicitHeight

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

        text: Hypr.activeToplevel?.title ?? qsTr("Desktop")
        font.pointSize: 12
        font.family: "Rubik"

        onTextChanged: {
            const next = root.current === text1 ? text2 : text1;
            next.text = elidedText;
            root.current = next;
        }
        onElideWidthChanged: root.current.text = elidedText
    }

    Behavior on implicitWidth {
        Anim {
            duration: MaterialEasing.expressiveEffectsTime
            easing.bezierCurve: MaterialEasing.expressiveEffects
        }
    }

    component Title: CustomText {
        id: text

		anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 7

        font.pointSize: metrics.font.pointSize
        font.family: metrics.font.family
        color: root.colour
        opacity: root.current === this ? 1 : 0

        width: implicitWidth
        height: implicitHeight

        Behavior on opacity {
            Anim {}
        }
    }
}
