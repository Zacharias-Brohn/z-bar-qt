pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

Item {
    id: root

    required property var lock

	anchors.fill: parent

    Image {
        anchors.fill: parent
        source: Players.active?.trackArtUrl ?? ""

        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: width
        sourceSize.height: height

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }

        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            Anim {
                duration: Appearance.anim.durations.extraLarge
            }
        }
    }

    Rectangle {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: Qt.rgba(0, 0, 0, 0.5)
            }
            GradientStop {
                position: 0.4
                color: Qt.rgba(0, 0, 0, 0.2)
            }
            GradientStop {
                position: 0.8
                color: Qt.rgba(0, 0, 0, 0)
            }
        }
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large

        CustomText {
            Layout.topMargin: Appearance.padding.large
            Layout.bottomMargin: Appearance.spacing.larger
            text: qsTr("Now playing")
            color: DynamicColors.palette.m3onSurfaceVariant
            font.family: Appearance.font.family.mono
            font.weight: 500
        }

        CustomText {
            Layout.fillWidth: true
            animate: true
            text: Players.active?.trackArtist ?? qsTr("No media")
            color: DynamicColors.palette.m3primary
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Appearance.font.size.large
            font.family: Appearance.font.family.mono
            font.weight: 600
            elide: Text.ElideRight
        }

        CustomText {
            Layout.fillWidth: true
            animate: true
            text: Players.active?.trackTitle ?? qsTr("No media")
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Appearance.font.size.larger
            font.family: Appearance.font.family.mono
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Appearance.spacing.large * 1.2
            Layout.bottomMargin: Appearance.padding.large

            spacing: Appearance.spacing.large

            PlayerControl {
                icon: "skip_previous"

                function onClicked(): void {
                    if (Players.active?.canGoPrevious)
                        Players.active.previous();
                }
            }

            PlayerControl {
                animate: true
                icon: active ? "pause" : "play_arrow"
                colour: "Primary"
                level: active ? 2 : 1
                active: Players.active?.isPlaying ?? false

                function onClicked(): void {
                    if (Players.active?.canTogglePlaying)
                        Players.active.togglePlaying();
                }
            }

            PlayerControl {
                icon: "skip_next"

                function onClicked(): void {
                    if (Players.active?.canGoNext)
                        Players.active.next();
                }
            }
        }
    }

    component PlayerControl: CustomRect {
        id: control

        property alias animate: controlIcon.animate
        property alias icon: controlIcon.text
        property bool active
        property string colour: "Secondary"
        property int level: 1

        function onClicked(): void {
        }

        Layout.preferredWidth: implicitWidth + (controlState.pressed ? Appearance.padding.normal * 2 : active ? Appearance.padding.small * 2 : 0)
        implicitWidth: controlIcon.implicitWidth + Appearance.padding.large * 2
        implicitHeight: controlIcon.implicitHeight + Appearance.padding.normal * 2

        color: active ? DynamicColors.palette[`m3${colour.toLowerCase()}`] : DynamicColors.palette[`m3${colour.toLowerCase()}Container`]
        radius: active || controlState.pressed ? Appearance.rounding.small : Appearance.rounding.normal

        Elevation {
            anchors.fill: parent
            radius: parent.radius
            z: -1
            level: controlState.containsMouse && !controlState.pressed ? control.level + 1 : control.level
        }

        StateLayer {
            id: controlState

            color: control.active ? DynamicColors.palette[`m3on${control.colour}`] : DynamicColors.palette[`m3on${control.colour}Container`]

            function onClicked(): void {
                control.onClicked();
            }
        }

        MaterialIcon {
            id: controlIcon

            anchors.centerIn: parent
            color: control.active ? DynamicColors.palette[`m3on${control.colour}`] : DynamicColors.palette[`m3on${control.colour}Container`]
            font.pointSize: Appearance.font.size.large
            fill: control.active ? 1 : 0

            Behavior on fill {
                Anim {}
            }
        }

        Behavior on Layout.preferredWidth {
            Anim {
                duration: Appearance.anim.durations.expressiveFastSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            }
        }

        Behavior on radius {
            Anim {
                duration: Appearance.anim.durations.expressiveFastSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            }
        }
    }
}
