import qs.Modules.Notifications.Sidebar.Utils.Cards
import qs.Config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var props
    required property var visibilities
    required property Item popouts

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 8

        IdleInhibit {}

        Toggles {
            visibilities: root.visibilities
            popouts: root.popouts
        }
    }
}
