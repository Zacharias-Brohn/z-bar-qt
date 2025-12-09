pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Config
import qs.Components
import qs.Daemons

Item {
    id: root

    implicitWidth: layout.implicitWidth + 10 * 2
    implicitHeight: layout.implicitHeight + 10 * 2

    required property var wrapper

    ButtonGroup {
        id: sinks
    }

    ButtonGroup {
        id: sources
    }

    ColumnLayout {
        id: layout

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        CustomText {
            text: qsTr("Output device")
            font.weight: 500
        }

        Repeater {
            model: Audio.sinks

            CustomRadioButton {
                id: control

                required property PwNode modelData

                ButtonGroup.group: sinks
                checked: Audio.sink?.id === modelData.id
                onClicked: Audio.setAudioSink(modelData)
                text: modelData.description
            }
        }

        CustomText {
            Layout.topMargin: 10
            text: qsTr("Input device")
            font.weight: 500
        }

        Repeater {
            model: Audio.sources

            CustomRadioButton {
                required property PwNode modelData

                ButtonGroup.group: sources
                checked: Audio.source?.id === modelData.id
                onClicked: Audio.setAudioSource(modelData)
                text: modelData.description
            }
        }

        CustomText {
            Layout.topMargin: 10
            Layout.bottomMargin: -7 / 2
            text: qsTr("Output Volume (%1)").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`)
            font.weight: 500
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: 10

            CustomSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: parent.implicitHeight

                value: Audio.volume
                onMoved: Audio.setVolume(value)

                Behavior on value {
                    Anim {}
                }
            }
        }

        CustomText {
            Layout.topMargin: 10
            Layout.bottomMargin: -7 / 2
            text: qsTr("Input Volume (%1)").arg(Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`)
            font.weight: 500
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: 10

            CustomSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: parent.implicitHeight

                value: Audio.sourceVolume
                onMoved: Audio.setSourceVolume(value)

                Behavior on value {
                    Anim {}
                }
            }
        }

        CustomRect {
            Layout.topMargin: 12
            visible: true

            implicitWidth: expandBtn.implicitWidth + 10 * 2
            implicitHeight: expandBtn.implicitHeight + 5

            radius: 4
            color: DynamicColors.palette.m3primaryContainer

            StateLayer {
                color: DynamicColors.palette.m3onPrimaryContainer

                function onClicked(): void {
                    Quickshell.execDetached(["app2unit", "--", "hyprpwcenter"]);
                    root.wrapper.hasCurrent = false;
                }
            }

            RowLayout {
                id: expandBtn

                anchors.centerIn: parent
                spacing: 7

                CustomText {
                    Layout.leftMargin: 7
                    text: qsTr("Open settings")
                    color: DynamicColors.palette.m3onPrimaryContainer
                }

                MaterialIcon {
                    Layout.topMargin: 2
                    text: "chevron_right"
                    color: DynamicColors.palette.m3onPrimaryContainer
                    font.pointSize: 18
                }
            }
        }
    }
}
