import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Io
import Quickshell.Widgets
import qs.Modules
import qs.Config
import Caelestia
import QtQuick.Effects

Item {
    id: root

    required property SystemTrayItem item
    required property PanelWindow bar
    property bool hasLoaded: false

    Image {
        id: icon

        property bool batteryHDPI: root.bar.screen.x < 0 && root.item.icon.includes("battery")
        property bool nmHDPI: root.bar.screen.x < 0 && root.item.icon.includes("nm-")

        anchors.centerIn: parent
        width: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
        height: batteryHDPI ? 26 : ( nmHDPI ? 25 : 22 )
        source: root.item.icon
        mipmap: true
        smooth: ( batteryHDPI || nmHDPI ) ? false : true
        asynchronous: true
        sourceSize.width: ( batteryHDPI || nmHDPI ) ? 16 : 22
        sourceSize.height: ( batteryHDPI || nmHDPI ) ? 16 : 22
        fillMode: Image.PreserveAspectFit

    }
}
