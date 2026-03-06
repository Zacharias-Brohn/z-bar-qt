pragma ComponentBehavior: Bound

import qs.Components
import qs.Config
import qs.Modules
import qs.Daemons
import qs.Helpers
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

CustomRect {
	id: root

	readonly property string appIcon: notifs.find(n => !n.closed && n.appIcon.length > 0)?.appIcon ?? ""
	required property Flickable container
	readonly property bool expanded: props.expandedNotifs.includes(modelData)
	readonly property string image: notifs.find(n => !n.closed && n.image.length > 0)?.image ?? ""
	required property string modelData
	readonly property int nonAnimHeight: {
		const headerHeight = header.implicitHeight + (root.expanded ? Math.round(7 / 2) : 0);
		const columnHeight = headerHeight + notifList.nonAnimHeight + column.Layout.topMargin + column.Layout.bottomMargin;
		return Math.round(Math.max(Config.notifs.sizes.image, columnHeight) + 10 * 2);
	}
	readonly property int notifCount: notifs.reduce((acc, n) => n.closed ? acc : acc + 1, 0)
	readonly property list<var> notifs: NotifServer.list.filter(n => n.appName === modelData)
	required property Props props
	readonly property int urgency: notifs.some(n => !n.closed && n.urgency === NotificationUrgency.Critical) ? NotificationUrgency.Critical : notifs.some(n => n.urgency === NotificationUrgency.Normal) ? NotificationUrgency.Normal : NotificationUrgency.Low
	required property var visibilities

	function toggleExpand(expand: bool): void {
		if (expand) {
			if (!expanded)
				props.expandedNotifs.push(modelData);
		} else if (expanded) {
			props.expandedNotifs.splice(props.expandedNotifs.indexOf(modelData), 1);
		}
	}

	anchors.left: parent?.left
	anchors.right: parent?.right
	clip: true
	color: DynamicColors.layer(DynamicColors.palette.m3surfaceContainer, 2)
	implicitHeight: content.implicitHeight + 10 * 2
	radius: 8

	Component.onDestruction: {
		if (notifCount === 0 && expanded)
			props.expandedNotifs.splice(props.expandedNotifs.indexOf(modelData), 1);
	}

	RowLayout {
		id: content

		anchors.left: parent.left
		anchors.margins: 10
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: 10

		Item {
			Layout.alignment: Qt.AlignLeft | Qt.AlignTop
			implicitHeight: Config.notifs.sizes.image
			implicitWidth: Config.notifs.sizes.image

			Component {
				id: imageComp

				Image {
					asynchronous: true
					cache: false
					fillMode: Image.PreserveAspectCrop
					height: Config.notifs.sizes.image
					source: Qt.resolvedUrl(root.image)
					width: Config.notifs.sizes.image
				}
			}

			Component {
				id: appIconComp

				CustomIcon {
					implicitSize: Math.round(Config.notifs.sizes.image * 0.6)
					layer.enabled: root.appIcon.endsWith("symbolic")
					source: Quickshell.iconPath(root.appIcon)
				}
			}

			Component {
				id: materialIconComp

				MaterialIcon {
					color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : root.urgency === NotificationUrgency.Low ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
					font.pointSize: 18
					text: Icons.getNotifIcon(root.notifs[0]?.summary, root.urgency)
				}
			}

			CustomClippingRect {
				anchors.fill: parent
				color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : root.urgency === NotificationUrgency.Low ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 3) : DynamicColors.palette.m3secondaryContainer
				radius: 1000

				Loader {
					anchors.centerIn: parent
					sourceComponent: root.image ? imageComp : root.appIcon ? appIconComp : materialIconComp
				}
			}

			Loader {
				active: root.appIcon && root.image
				anchors.bottom: parent.bottom
				anchors.right: parent.right

				sourceComponent: CustomRect {
					color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : root.urgency === NotificationUrgency.Low ? DynamicColors.palette.m3surfaceContainerHigh : DynamicColors.palette.m3secondaryContainer
					implicitHeight: Config.notifs.sizes.badge
					implicitWidth: Config.notifs.sizes.badge
					radius: 1000

					CustomIcon {
						anchors.centerIn: parent
						implicitSize: Math.round(Config.notifs.sizes.badge * 0.6)
						layer.enabled: root.appIcon.endsWith("symbolic")
						source: Quickshell.iconPath(root.appIcon)
					}
				}
			}
		}

		ColumnLayout {
			id: column

			Layout.bottomMargin: -10 / 2
			Layout.fillWidth: true
			Layout.topMargin: -10
			spacing: 0

			RowLayout {
				id: header

				Layout.bottomMargin: root.expanded ? Math.round(7 / 2) : 0
				Layout.fillWidth: true
				spacing: 5

				Behavior on Layout.bottomMargin {
					Anim {
					}
				}

				CustomText {
					Layout.fillWidth: true
					color: DynamicColors.palette.m3onSurfaceVariant
					elide: Text.ElideRight
					font.pointSize: 11
					text: root.modelData
				}

				CustomText {
					animate: true
					color: DynamicColors.palette.m3outline
					font.pointSize: 11
					text: root.notifs.find(n => !n.closed)?.timeStr ?? ""
				}

				CustomRect {
					color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3error : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 3)
					implicitHeight: groupCount.implicitHeight + 10
					implicitWidth: expandBtn.implicitWidth + 7 * 2
					radius: 1000

					StateLayer {
						function onClicked(): void {
							root.toggleExpand(!root.expanded);
						}

						color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurface
					}

					RowLayout {
						id: expandBtn

						anchors.centerIn: parent
						spacing: 7 / 2

						CustomText {
							id: groupCount

							Layout.leftMargin: 10 / 2
							animate: true
							color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurface
							font.pointSize: 11
							text: root.notifCount
						}

						MaterialIcon {
							Layout.rightMargin: -10 / 2
							Layout.topMargin: root.expanded ? -Math.floor(7 / 2) : 0
							color: root.urgency === NotificationUrgency.Critical ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurface
							rotation: root.expanded ? 180 : 0
							text: "expand_more"

							Behavior on Layout.topMargin {
								Anim {
									duration: MaterialEasing.expressiveEffectsTime
									easing.bezierCurve: MaterialEasing.expressiveEffects
								}
							}
							Behavior on rotation {
								Anim {
									duration: MaterialEasing.expressiveEffectsTime
									easing.bezierCurve: MaterialEasing.expressiveEffects
								}
							}
						}
					}
				}
			}

			NotifGroupList {
				id: notifList

				container: root.container
				expanded: root.expanded
				notifs: root.notifs
				props: root.props
				visibilities: root.visibilities

				onRequestToggleExpand: expand => root.toggleExpand(expand)
			}
		}
	}
}
