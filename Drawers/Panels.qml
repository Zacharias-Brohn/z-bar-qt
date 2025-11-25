import Quickshell
import QtQuick
import QtQuick.Shapes
import qs.Modules as Modules
import qs.Config

Item {
    id: root

    required property ShellScreen screen
    required property Item bar

    readonly property alias popouts: popouts

    anchors.fill: parent
    anchors.margins: 8
    anchors.topMargin: bar.implicitHeight

    Modules.Wrapper {
        id: popouts

        screen: root.screen

        anchors.top: parent.top
        x: {
            const off = currentCenter - 8 - nonAnimWidth / 2;
            const diff = root.width - Math.floor(off + nonAnimWidth);
            if (diff < 0)
                return off + diff;
            return Math.floor(Math.max(off, 0));
        }
    }
}
