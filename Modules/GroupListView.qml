import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Daemons

Repeater {
    model: ScriptModel {
        values: {
            const map = new Map();
            for ( const n of NotifServer.notClosed )
            map.set( n.appName, null );
            for ( const n of NotifServer.list )
            map.set( n.appName, null );
            return [ ...map.keys() ];
        }
        onValuesChanged: {
            root.flagChanged();
        }
    }

    Column {
        id: groupColumn
        required property string modelData
        property list<var> notifications: NotifServer.list.filter( n => n.appName === modelData )
        width: parent.width
        spacing: 10

        property bool shouldShow: false
        property bool isExpanded: false
        property bool collapseAnimRunning: false
        property color textColor: Config.useDynamicColors ? DynamicColors.palette.m3onSurface : "white"

        function closeAll(): void {
            for ( const n of NotifServer.notClosed.filter( n => n.appName === modelData ))
            n.close();
        }

        Behavior on height {
            Anim {}
        }

        Behavior on y {
            Anim {
                duration: MaterialEasing.expressiveEffectsTime
                easing.bezierCurve: MaterialEasing.expressiveEffects
            }
        }

        add: Transition {
            id: addTrans
            SequentialAnimation {
                PauseAnimation {
                    duration: ( addTrans.ViewTransition.index - addTrans.ViewTransition.targetIndexes[ 0 ]) * 30
                }
                ParallelAnimation {
                    NumberAnimation {
                        properties: "y";
                        from: addTrans.ViewTransition.destination.y - (height / 2);
                        to: addTrans.ViewTransition.destination.y;
                        duration: 100;
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        properties: "opacity";
                        from: 0;
                        to: 1;
                        duration: 100;
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        properties: "scale";
                        from: 0.7;
                        to: 1.0;
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Timer {
            interval: addTrans.ViewTransition.targetIndexes.length * 30 + 100
            running: groupColumn.isExpanded
            repeat: false
            onTriggered: {
                groupColumn.shouldShow = true;
                console.log("ran timer");
            }
        }

        move: Transition {
            id: moveTrans
            NumberAnimation {
                properties: "y";
                duration: 100;
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                properties: "opacity, scale";
                to: 1.0;
            }
        }

        RowLayout {
            width: parent.width
            height: 30

            Text {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.leftMargin: 5
                text: groupColumn.modelData
                color: groupColumn.textColor
                font.pointSize: 14
                font.bold: true
            }

            Rectangle {
                id: collapseRect

                property color notifyBgColor: Config.useDynamicColors ? DynamicColors.palette.m3primary : "#E53935"
                property color notifyColor: Config.useDynamicColors ? DynamicColors.palette.m3onPrimary : "#FFCDD2"

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.fillHeight: true
                Layout.preferredWidth: 30
                color: !groupColumn.isExpanded ? collapseRect.notifyBgColor : ( collapseArea.containsMouse ? "#15FFFFFF" : "transparent" )
                radius: groupColumn.isExpanded ? 4 : height / 2
                visible: true

                Text {
                    anchors.centerIn: parent
                    text: groupColumn.isExpanded ? "\ue944" : groupColumn.notifications.length
                    font.family: groupColumn.isExpanded ? "Material Symbols Rounded" : "Rubik"
                    font.pointSize: 18
                    color: groupColumn.isExpanded ? groupColumn.textColor : collapseRect.notifyColor
                }

                MouseArea {
                    id: collapseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        groupColumn.collapseAnimRunning = true;
                    }
                }
            }
        }
        NotifGroupRepeater { id: groupRepeater }
    }
}
