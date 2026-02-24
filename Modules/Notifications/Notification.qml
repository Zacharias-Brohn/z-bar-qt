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

	property bool expanded: Config.notifs.openExpanded
	readonly property bool hasAppIcon: modelData.appIcon.length > 0
	readonly property bool hasImage: modelData.image.length > 0
	required property NotifServer.Notif modelData
	readonly property int nonAnimHeight: summary.implicitHeight + (root.expanded ? appName.height + body.height + actions.height + actions.anchors.topMargin : bodyPreview.height) + inner.anchors.margins * 2

	color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondaryContainer : DynamicColors.tPalette.m3surfaceContainer
	implicitHeight: inner.implicitHeight
	implicitWidth: Config.notifs.sizes.width
	radius: 6
	x: Config.notifs.sizes.width

	Behavior on x {
		Anim {
			easing.bezierCurve: MaterialEasing.expressiveEffects
		}
	}

	Component.onCompleted: {
		x = 0;
		modelData.lock(this);
	}
	Component.onDestruction: modelData.unlock(this)

	MouseArea {
		property int startY

		acceptedButtons: Qt.LeftButton | Qt.MiddleButton
		anchors.fill: parent
		cursorShape: root.expanded && body.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
		drag.axis: Drag.XAxis
		drag.target: parent
		hoverEnabled: true
		preventStealing: true

		onClicked: event => {
			if (!Config.notifs.actionOnClick || event.button !== Qt.LeftButton)
				return;

			const actions = root.modelData.actions;
			if (actions?.length === 1)
				actions[0].invoke();
		}
		onEntered: root.modelData.timer.stop()
		onExited: {
			if (!pressed)
				root.modelData.timer.start();
		}
		onPositionChanged: event => {
			if (pressed) {
				const diffY = event.y - startY;
				if (Math.abs(diffY) > Config.notifs.expandThreshold)
					root.expanded = diffY > 0;
			}
		}
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

		Item {
			id: inner

			anchors.left: parent.left
			anchors.margins: 8
			anchors.right: parent.right
			anchors.top: parent.top
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
				asynchronous: true
				height: Config.notifs.sizes.image
				visible: root.hasImage || root.hasAppIcon
				width: Config.notifs.sizes.image

				sourceComponent: ClippingRectangle {
					implicitHeight: Config.notifs.sizes.image
					implicitWidth: Config.notifs.sizes.image
					radius: 1000

					Image {
						anchors.fill: parent
						asynchronous: true
						cache: false
						fillMode: Image.PreserveAspectCrop
						mipmap: true
						source: Qt.resolvedUrl(root.modelData.image)
					}
				}
			}

			Loader {
				id: appIcon

				active: root.hasAppIcon || !root.hasImage
				anchors.bottom: root.hasImage ? image.bottom : undefined
				anchors.horizontalCenter: root.hasImage ? undefined : image.horizontalCenter
				anchors.right: root.hasImage ? image.right : undefined
				anchors.verticalCenter: root.hasImage ? undefined : image.verticalCenter
				asynchronous: true

				sourceComponent: CustomRect {
					color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2) : DynamicColors.palette.m3secondaryContainer
					implicitHeight: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
					implicitWidth: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
					radius: 1000

					Loader {
						id: icon

						active: root.hasAppIcon
						anchors.centerIn: parent
						asynchronous: true
						height: Math.round(parent.width * 0.6)
						width: Math.round(parent.width * 0.6)

						sourceComponent: CustomIcon {
							anchors.fill: parent
							layer.enabled: root.modelData.appIcon.endsWith("symbolic")
							source: Quickshell.iconPath(root.modelData.appIcon)
						}
					}

					Loader {
						active: !root.hasAppIcon
						anchors.centerIn: parent
						anchors.horizontalCenterOffset: -18 * 0.02
						anchors.verticalCenterOffset: 18 * 0.02
						asynchronous: true

						sourceComponent: MaterialIcon {
							color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
							font.pointSize: 18
							text: Icons.getNotifIcon(root.modelData.summary, root.modelData.urgency)
						}
					}
				}
			}

			CustomText {
				id: appName

				anchors.left: image.right
				anchors.leftMargin: 10
				anchors.top: parent.top
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 10
				maximumLineCount: 1
				opacity: root.expanded ? 1 : 0
				text: appNameMetrics.elidedText

				Behavior on opacity {
					Anim {
					}
				}
			}

			TextMetrics {
				id: appNameMetrics

				elide: Text.ElideRight
				elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - 7 * 3
				font.family: appName.font.family
				font.pointSize: appName.font.pointSize
				text: root.modelData.appName
			}

			CustomText {
				id: summary

				anchors.left: image.right
				anchors.leftMargin: 10
				anchors.top: parent.top
				animate: true
				height: implicitHeight
				maximumLineCount: 1
				text: summaryMetrics.elidedText

				Behavior on height {
					Anim {
					}
				}
				states: State {
					name: "expanded"
					when: root.expanded

					PropertyChanges {
						summary.maximumLineCount: undefined
					}

					AnchorChanges {
						anchors.top: appName.bottom
						target: summary
					}
				}
				transitions: Transition {
					PropertyAction {
						property: "maximumLineCount"
						target: summary
					}

					AnchorAnimation {
						duration: MaterialEasing.expressiveEffectsTime
						easing.bezierCurve: MaterialEasing.expressiveEffects
						easing.type: Easing.BezierSpline
					}
				}
			}

			TextMetrics {
				id: summaryMetrics

				elide: Text.ElideRight
				elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - 7 * 3
				font.family: summary.font.family
				font.pointSize: summary.font.pointSize
				text: root.modelData.summary
			}

			CustomText {
				id: timeSep

				anchors.left: summary.right
				anchors.leftMargin: 7
				anchors.top: parent.top
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 10
				text: "•"

				states: State {
					name: "expanded"
					when: root.expanded

					AnchorChanges {
						anchors.left: appName.right
						target: timeSep
					}
				}
				transitions: Transition {
					AnchorAnimation {
						duration: MaterialEasing.expressiveEffectsTime
						easing.bezierCurve: MaterialEasing.expressiveEffects
						easing.type: Easing.BezierSpline
					}
				}
			}

			CustomText {
				id: time

				anchors.left: timeSep.right
				anchors.leftMargin: 7
				anchors.top: parent.top
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 10
				horizontalAlignment: Text.AlignLeft
				text: root.modelData.timeStr
			}

			Item {
				id: expandBtn

				anchors.right: parent.right
				anchors.top: parent.top
				implicitHeight: expandIcon.height
				implicitWidth: expandIcon.height

				StateLayer {
					function onClicked() {
						root.expanded = !root.expanded;
					}

					color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
					radius: 1000
				}

				MaterialIcon {
					id: expandIcon

					anchors.centerIn: parent
					animate: true
					font.pointSize: 13
					text: root.expanded ? "expand_less" : "expand_more"
				}
			}

			CustomText {
				id: bodyPreview

				anchors.left: summary.left
				anchors.right: expandBtn.left
				anchors.rightMargin: 7
				anchors.top: summary.bottom
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 10
				opacity: root.expanded ? 0 : 1
				text: bodyPreviewMetrics.elidedText
				textFormat: Text.MarkdownText

				Behavior on opacity {
					Anim {
					}
				}
			}

			TextMetrics {
				id: bodyPreviewMetrics

				elide: Text.ElideRight
				elideWidth: bodyPreview.width
				font.family: bodyPreview.font.family
				font.pointSize: bodyPreview.font.pointSize
				text: root.modelData.body
			}

			CustomText {
				id: body

				anchors.left: summary.left
				anchors.right: expandBtn.left
				anchors.rightMargin: 7
				anchors.top: summary.bottom
				animate: true
				color: DynamicColors.palette.m3onSurfaceVariant
				font.pointSize: 10
				height: text ? implicitHeight : 0
				opacity: root.expanded ? 1 : 0
				text: root.modelData.body
				textFormat: Text.MarkdownText
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere

				Behavior on opacity {
					Anim {
					}
				}

				onLinkActivated: link => {
					if (!root.expanded)
						return;

					Quickshell.execDetached(["app2unit", "-O", "--", link]);
					root.modelData.popup = false;
				}
			}

			RowLayout {
				id: actions

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: body.bottom
				anchors.topMargin: 7
				opacity: root.expanded ? 1 : 0
				spacing: 10

				Behavior on opacity {
					Anim {
					}
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
						Action {
						}
					}
				}
			}
		}
	}

	component Action: CustomRect {
		id: action

		required property var modelData

		Layout.preferredHeight: actionText.height + 4 * 2
		Layout.preferredWidth: actionText.width + 8 * 2
		color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3secondary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
		implicitHeight: actionText.height + 4 * 2
		implicitWidth: actionText.width + 8 * 2
		radius: 1000

		StateLayer {
			function onClicked(): void {
				action.modelData.invoke();
			}

			color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurface
			radius: 1000
		}

		CustomText {
			id: actionText

			anchors.centerIn: parent
			color: root.modelData.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onSecondary : DynamicColors.palette.m3onSurfaceVariant
			font.pointSize: 10
			text: actionTextMetrics.elidedText
		}

		TextMetrics {
			id: actionTextMetrics

			elide: Text.ElideRight
			elideWidth: {
				const numActions = root.modelData.actions.length + 1;
				return (inner.width - actions.spacing * (numActions - 1)) / numActions - 8 * 2;
			}
			font.family: actionText.font.family
			font.pointSize: actionText.font.pointSize
			text: action.modelData.text
		}
	}
}
