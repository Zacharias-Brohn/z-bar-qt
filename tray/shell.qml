pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick.Layouts

import qs.Data as Dat
import qs.Generics as Gen

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
        left: true
    }

    implicitHeight: 35

    RowLayout {
        id: trayLayout
        anchors.fill: parent

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: trayItemRow

                anchors.fill: parent
                orientation: ListView.Horizontal
                snapMode: ListView.SnapToItem
                spacing: 10

                add: Transition {
                    SequentialAnimation {
                        NumberAnimation {
                            duration: 0
                            property: "opacity"
                            to: 0
                        }

                        PauseAnimation {
                            duration: addDisAni.duration / 2
                        }

                        NumberAnimation {
                            duration: Dat.MaterialEasing.emphasizedTime
                            easing.bezierCurve: Dat.MaterialEasing.emphasized
                            from: 0
                            property: "opacity"
                            to: 1
                        }
                    }
                }
                addDisplaced: Transition {
                    SequentialAnimation {
                        NumberAnimation {
                            id: addDisAni

                            duration: Dat.MaterialEasing.emphasizedDecelTime
                            easing.bezierCurve: Dat.MaterialEasing.emphasizedDecel
                            properties: "x"
                        }
                    }
                }
                delegate: TrayItem {
                }
                model: ScriptModel {
                    values: [...SystemTray.items.values]
                }
                remove: Transition {
                    NumberAnimation {
                        id: removeAni

                        duration: Dat.MaterialEasing.emphasizedTime
                        easing.bezierCurve: Dat.MaterialEasing.emphasized
                        from: 1
                        property: "opacity"
                        to: 0
                    }
                }
                removeDisplaced: Transition {
                    SequentialAnimation {
                        PauseAnimation {
                            duration: removeAni.duration / 2
                        }

                        NumberAnimation {
                            duration: Dat.MaterialEasing.emphasizedDecelTime
                            easing.bezierCurve: Dat.MaterialEasing.emphasizedDecel
                            properties: "x"
                        }
                    }
                }
            }
        }
    }
}
