pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import qs.Helpers
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

CustomRect {
    id: root

    required property NotifServer.Notif modelData
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property int nonAnimHeight: summary.implicitHeight + (root.expanded ? appName.height + body.height + actions.height + actions.anchors.topMargin : bodyPreview.height) + inner.anchors.margins * 2
    property bool expanded: Config.notifs.openExpanded

    color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondaryContainer : DynamicColors.tPalette.m3surfaceContainer
    radius: 6
    implicitWidth: Config.notifs.sizes.width
    implicitHeight: inner.implicitHeight

    x: Config.notifs.sizes.width
    Component.onCompleted: {
        x = 0;
        modelData.lock(this);
    }
    Component.onDestruction: modelData.unlock(this)

    Behavior on x {
        Anim {
			easing.bezierCurve: MaterialEasing.expressiveEffects
        }
    }

    MouseArea {
        property int startY

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.expanded && body.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        onEntered: root.modelData.timer.stop()
        onExited: {
            if (!pressed)
                root.modelData.timer.start();
        }

        drag.target: parent
        drag.axis: Drag.XAxis

        onPressed: event => {
            root.modelData.timer.stop();
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                root.modelData.close();
        }
        onReleased: event => {
            if (!containsMouse)
                root.modelData.timer.start();

            if (Math.abs(root.x) < Config.notifs.sizes.width * Config.notifs.clearThreshold)
                root.x = 0;
            else
                root.modelData.popup = false;
        }
        onPositionChanged: event => {
            if (pressed) {
                const diffY = event.y - startY;
                if (Math.abs(diffY) > Config.notifs.expandThreshold)
                    root.expanded = diffY > 0;
            }
        }
        onClicked: event => {
            if (!Config.notifs.actionOnClick || event.button !== Qt.LeftButton)
                return;

            const actions = root.modelData.actions;
            if (actions?.length === 1)
                actions[0].invoke();
        }

        Item {
            id: inner

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8

            implicitHeight: root.nonAnimHeight

            Behavior on implicitHeight {
                Anim {
					duration: MaterialEasing.expressiveEffectsTime
					easing.bezierCurve: MaterialEasing.expressiveEffects
                }
            }

            Loader {
                id: image

                active: root.hasImage

                anchors.left: parent.left
                anchors.top: parent.top
                width: Config.notifs.sizes.image
                height: Config.notifs.sizes.image
                visible: root.hasImage || root.hasAppIcon
				asynchronous: true

                sourceComponent: ClippingRectangle {
                    radius: 1000
                    implicitWidth: Config.notifs.sizes.image
                    implicitHeight: Config.notifs.sizes.image

                    Image {
                        anchors.fill: parent
                        source: Qt.resolvedUrl(root.modelData.image)
                        fillMode: Image.PreserveAspectCrop
						mipmap: true
                        cache: false
                        asynchronous: true
                    }
                }
            }

            Loader {
                id: appIcon

                active: root.hasAppIcon || !root.hasImage

                anchors.horizontalCenter: root.hasImage ? undefined : image.horizontalCenter
                anchors.verticalCenter: root.hasImage ? undefined : image.verticalCenter
                anchors.right: root.hasImage ? image.right : undefined
                anchors.bottom: root.hasImage ? image.bottom : undefined
				asynchronous: true

                sourceComponent: CustomRect {
                    radius: 1000
                    color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2) : DynamicColors.palette.m3secondaryContainer
                    implicitWidth: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
                    implicitHeight: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image

                    Loader {
                        id: icon

                        active: root.hasAppIcon

                        anchors.centerIn: parent
						asynchronous: true

                        width: Math.round(parent.width * 0.6)
                        height: Math.round(parent.width * 0.6)

                        sourceComponent: CustomIcon {
                            anchors.fill: parent
                            source: Quickshell.iconPath(root.modelData.appIcon)
                            layer.enabled: root.modelData.appIcon.endsWith("symbolic")
                        }
                    }

                    Loader {
                        active: !root.hasAppIcon
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -18 * 0.02
                        anchors.verticalCenterOffset: 18 * 0.02
						asynchronous: true

                        sourceComponent: MaterialIcon {
                            text: Icons.getNotifIcon(root.modelData.summary, root.modelData.urgency)

                            color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
                            font.pointSize: 18
                        }
                    }
                }
            }

            CustomText {
                id: appName

                anchors.top: parent.top
                anchors.left: image.right
                anchors.leftMargin: 10

                animate: true
                text: appNameMetrics.elidedText
                maximumLineCount: 1
                color: DynamicColors.palette.m3onSurfaceVariant
                font.pointSize: 10

                opacity: root.expanded ? 1 : 0

                Behavior on opacity {
                    Anim {}
                }
            }

            TextMetrics {
                id: appNameMetrics

                text: root.modelData.appName
                font.family: appName.font.family
                font.pointSize: appName.font.pointSize
                elide: Text.ElideRight
                elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - 7 * 3
            }

            CustomText {
                id: summary

                anchors.top: parent.top
                anchors.left: image.right
                anchors.leftMargin: 10

                animate: true
                text: summaryMetrics.elidedText
                maximumLineCount: 1
                height: implicitHeight

                states: State {
                    name: "expanded"
                    when: root.expanded

                    PropertyChanges {
                        summary.maximumLineCount: undefined
                    }

                    AnchorChanges {
                        target: summary
                        anchors.top: appName.bottom
                    }
                }

                transitions: Transition {
                    PropertyAction {
                        target: summary
                        property: "maximumLineCount"
                    }
                    AnchorAnimation {
						easing.type: Easing.BezierSpline
						duration: MaterialEasing.expressiveEffectsTime
						easing.bezierCurve: MaterialEasing.expressiveEffects
                    }
                }

                Behavior on height {
                    Anim {}
                }
            }

            TextMetrics {
                id: summaryMetrics

                text: root.modelData.summary
                font.family: summary.font.family
                font.pointSize: summary.font.pointSize
                elide: Text.ElideRight
                elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - 7 * 3
            }

            CustomText {
                id: timeSep

                anchors.top: parent.top
                anchors.left: summary.right
                anchors.leftMargin: 7

                text: "•"
                color: DynamicColors.palette.m3onSurfaceVariant
                font.pointSize: 10

                states: State {
                    name: "expanded"
                    when: root.expanded

                    AnchorChanges {
                        target: timeSep
                        anchors.left: appName.right
                    }
                }

                transitions: Transition {
                    AnchorAnimation {
						easing.type: Easing.BezierSpline
						duration: MaterialEasing.expressiveEffectsTime
						easing.bezierCurve: MaterialEasing.expressiveEffects
                    }
                }
            }

            CustomText {
                id: time

                anchors.top: parent.top
                anchors.left: timeSep.right
                anchors.leftMargin: 7

                animate: true
                horizontalAlignment: Text.AlignLeft
                text: root.modelData.timeStr
                color: DynamicColors.palette.m3onSurfaceVariant
                font.pointSize: 10
            }

            Item {
                id: expandBtn

                anchors.right: parent.right
                anchors.top: parent.top

                implicitWidth: expandIcon.height
                implicitHeight: expandIcon.height

                StateLayer {
                    radius: 1000
                    color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface

                    function onClicked() {
                        root.expanded = !root.expanded;
                    }
                }

                MaterialIcon {
                    id: expandIcon

                    anchors.centerIn: parent

                    animate: true
                    text: root.expanded ? "expand_less" : "expand_more"
                    font.pointSize: 13
                }
            }

            CustomText {
                id: bodyPreview

                anchors.left: summary.left
                anchors.right: expandBtn.left
                anchors.top: summary.bottom
                anchors.rightMargin: 7

                animate: true
                textFormat: Text.MarkdownText
                text: bodyPreviewMetrics.elidedText
                color: DynamicColors.palette.m3onSurfaceVariant
                font.pointSize: 10

                opacity: root.expanded ? 0 : 1

                Behavior on opacity {
                    Anim {}
                }
            }

            TextMetrics {
                id: bodyPreviewMetrics

                text: root.modelData.body
                font.family: bodyPreview.font.family
                font.pointSize: bodyPreview.font.pointSize
                elide: Text.ElideRight
                elideWidth: bodyPreview.width
            }

            CustomText {
                id: body

                anchors.left: summary.left
                anchors.right: expandBtn.left
                anchors.top: summary.bottom
                anchors.rightMargin: 7

                animate: true
                textFormat: Text.MarkdownText
                text: root.modelData.body
                color: DynamicColors.palette.m3onSurfaceVariant
                font.pointSize: 10
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                height: text ? implicitHeight : 0

                onLinkActivated: link => {
                    if (!root.expanded)
                        return;

                    Quickshell.execDetached(["app2unit", "-O", "--", link]);
                    root.modelData.popup = false;
                }

                opacity: root.expanded ? 1 : 0

                Behavior on opacity {
                    Anim {}
                }
            }

            RowLayout {
                id: actions

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: body.bottom
                anchors.topMargin: 7

                spacing: 10

                opacity: root.expanded ? 1 : 0

                Behavior on opacity {
                    Anim {}
                }

                Action {
                    modelData: QtObject {
                        readonly property string text: qsTr("Close")
                        function invoke(): void {
                            root.modelData.close();
                        }
                    }
                }

                Repeater {
                    model: root.modelData.actions

                    delegate: Component {
                        Action {}
                    }
                }
            }
        }
    }

    component Action: CustomRect {
        id: action

        required property var modelData

        radius: 1000
        color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)

        Layout.preferredWidth: actionText.width + 8 * 2
        Layout.preferredHeight: actionText.height + 4 * 2
        implicitWidth: actionText.width + 8 * 2
        implicitHeight: actionText.height + 4 * 2

        StateLayer {
            radius: 1000
            color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurface

            function onClicked(): void {
                action.modelData.invoke();
            }
        }

        CustomText {
            id: actionText

            anchors.centerIn: parent
            text: actionTextMetrics.elidedText
            color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurfaceVariant
            font.pointSize: 10
        }

        TextMetrics {
            id: actionTextMetrics

            text: action.modelData.text
            font.family: actionText.font.family
            font.pointSize: actionText.font.pointSize
            elide: Text.ElideRight
            elideWidth: {
                const numActions = root.modelData.actions.length + 1;
                return (inner.width - actions.spacing * (numActions - 1)) / numActions - 8 * 2;
            }
        }
    }
}
