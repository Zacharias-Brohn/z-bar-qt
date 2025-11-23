import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3
import qs.Daemons
import qs.Config

RowLayout {
    id: root

    property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3onSurface : "white"

    Layout.fillWidth: true

    Switch {
        id: dndSwitch
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        Layout.fillWidth: true
        text: "Do Not Disturb"
        focus: false
        activeFocusOnTab: false
        focusPolicy: Qt.NoFocus
        onCheckedChanged: {
            NotifServer.dnd = dndSwitch.checked;
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

        Text {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            text: "Clear all"
            color: root.textColor
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            color: clearArea.containsMouse ? "#15FFFFFF" : "transparent"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: "\ue0b8"
                font.family: "Material Symbols Rounded"
                font.pointSize: 18
                color: root.textColor
            }

            MouseArea {
                id: clearArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    for ( const n of NotifServer.list.filter( n => !n.closed ))
                        n.close();
                }
            }
        }
    }
}
