pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Config
import qs.Components

Item {
    id: root

    implicitWidth: layout.implicitWidth + 10 * 2
    implicitHeight: layout.implicitHeight + 10 * 2

    ButtonGroup {
        id: sinks
    }

    ButtonGroup {
        id: sources
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
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

            StyledRadioButton {
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
            text: qsTr("Volume (%1)").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`)
            font.weight: 500
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: 10 * 3

            onWheel: event => {
                if (event.angleDelta.y > 0)
                    Audio.incrementVolume();
                else if (event.angleDelta.y < 0)
                    Audio.decrementVolume();
            }

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

        CustomRect {
            Layout.topMargin: 12
            visible: true

            implicitWidth: expandBtn.implicitWidth + 10 * 2
            implicitHeight: expandBtn.implicitHeight + 5

            radius: 17
            color: DynamicColors.palette.m3primaryContainer

            StateLayer {
                color: DynamicColors.palette.m3onPrimaryContainer

                function onClicked(): void {
                    root.wrapper.hasCurrent = false;
                    Quickshell.execDetached(["app2unit", "--", "pavucontrol"]);
                }
            }

            RowLayout {
                id: expandBtn

                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.leftMargin: Appearance.padding.smaller
                    text: qsTr("Open settings")
                    color: Colours.palette.m3onPrimaryContainer
                }

                MaterialIcon {
                    text: "chevron_right"
                    color: Colours.palette.m3onPrimaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }
        }
    }
}
