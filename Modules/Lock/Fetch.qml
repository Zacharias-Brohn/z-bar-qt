pragma ComponentBehavior: Bound

import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config

ColumnLayout {
    id: root

    anchors.fill: parent
    anchors.margins: Appearance.padding.large * 2
    anchors.topMargin: Appearance.padding.large

    spacing: Appearance.spacing.small

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: false
        spacing: Appearance.spacing.normal

        CustomRect {
            implicitWidth: prompt.implicitWidth + Appearance.padding.normal * 2
            implicitHeight: prompt.implicitHeight + Appearance.padding.normal * 2

            color: DynamicColors.palette.m3primary
            radius: Appearance.rounding.small

            MonoText {
                id: prompt

                anchors.centerIn: parent
                text: ">"
                font.pointSize: root.width > 400 ? Appearance.font.size.larger : Appearance.font.size.normal
                color: DynamicColors.palette.m3onPrimary
            }
        }

        MonoText {
            Layout.fillWidth: true
            text: "caelestiafetch.sh"
            font.pointSize: root.width > 400 ? Appearance.font.size.larger : Appearance.font.size.normal
            elide: Text.ElideRight
        }

        WrappedLoader {
            Layout.fillHeight: true
            active: !iconLoader.active

            sourceComponent: OsLogo {}
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: false
        spacing: height * 0.15

        WrappedLoader {
            id: iconLoader

            Layout.fillHeight: true
            active: root.width > 320

            sourceComponent: OsLogo {}
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.padding.normal
            Layout.bottomMargin: Appearance.padding.normal
            Layout.leftMargin: iconLoader.active ? 0 : width * 0.1
            spacing: Appearance.spacing.normal

            WrappedLoader {
                Layout.fillWidth: true
                active: !batLoader.active && root.height > 200

                sourceComponent: FetchText {
                    text: `OS  : ${SystemInfo.osPrettyName || SysInfo.osName}`
                }
            }

            WrappedLoader {
                Layout.fillWidth: true
                active: root.height > (batLoader.active ? 200 : 110)

                sourceComponent: FetchText {
                    text: `WM  : ${SystemInfo.wm}`
                }
            }

            WrappedLoader {
                Layout.fillWidth: true
                active: !batLoader.active || root.height > 110

                sourceComponent: FetchText {
                    text: `USER: ${SystemInfo.user}`
                }
            }

            FetchText {
                text: `UP  : ${SystemInfo.uptime}`
            }

            WrappedLoader {
                id: batLoader

                Layout.fillWidth: true
                active: UPower.displayDevice.isLaptopBattery

                sourceComponent: FetchText {
                    text: `BATT: ${[UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state) ? "(+) " : ""}${Math.round(UPower.displayDevice.percentage * 100)}%`
                }
            }
        }
    }

    WrappedLoader {
        Layout.alignment: Qt.AlignHCenter
        active: root.height > 180

        sourceComponent: RowLayout {
            spacing: Appearance.spacing.large

            Repeater {
                model: Math.max(0, Math.min(8, root.width / (Appearance.font.size.larger * 2 + Appearance.spacing.large)))

                CustomRect {
                    required property int index

                    implicitWidth: implicitHeight
                    implicitHeight: Appearance.font.size.larger * 2
                    color: DynamicColors.palette[`term${index}`]
                    radius: Appearance.rounding.small
                }
            }
        }
    }

    component WrappedLoader: Loader {
        visible: active
    }

    component OsLogo: ColoredIcon {
        source: SystemInfo.osLogo
        implicitSize: height
        color: DynamicColors.palette.m3primary
        layer.enabled: Config.lock.recolorLogo || SystemInfo.isDefaultLogo
    }

    component FetchText: MonoText {
        Layout.fillWidth: true
        font.pointSize: root.width > 400 ? Appearance.font.size.larger : Appearance.font.size.normal
        elide: Text.ElideRight
    }

    component MonoText: CustomText {
        font.family: Appearance.font.family.mono
    }
}
