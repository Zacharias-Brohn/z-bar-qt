pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

CustomRect {
	id: root

	readonly property string appIcon: notifs.find(n => n.appIcon.length > 0)?.appIcon ?? ""
	property bool expanded
	readonly property string image: notifs.find(n => n.image.length > 0)?.image ?? ""
	required property string modelData
	readonly property list<var> notifs: NotifServer.list.filter(notif => notif.appName === modelData)
	readonly property string urgency: notifs.some(n => n.urgency === NotificationUrgency.Critical) ? "critical" : notifs.some(n => n.urgency === NotificationUrgency.Normal) ? "normal" : "low"

	anchors.left: parent?.left
	anchors.right: parent?.right
	clip: true
	color: root.urgency === "critical" ? DynamicColors.palette.m3secondaryContainer : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHigh, 2)
	implicitHeight: content.implicitHeight + Appearance.padding.normal * 2
	radius: Appearance.rounding.normal

	Behavior on implicitHeight {
		Anim {
			duration: Appearance.anim.durations.expressiveDefaultSpatial
			easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
		}
	}

	RowLayout {
		id: content

		anchors.left: parent.left
		anchors.margins: Appearance.padding.normal
		anchors.right: parent.right
		anchors.top: parent.top
		spacing: Appearance.spacing.normal

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

				ColoredIcon {
					color: root.urgency === "critical" ? DynamicColors.palette.m3onError : root.urgency === "low" ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
					implicitSize: Math.round(Config.notifs.sizes.image * 0.6)
					layer.enabled: root.appIcon.endsWith("symbolic")
					source: Quickshell.iconPath(root.appIcon)
				}
			}

			Component {
				id: materialIconComp

				MaterialIcon {
					color: root.urgency === "critical" ? DynamicColors.palette.m3onError : root.urgency === "low" ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
					font.pointSize: Appearance.font.size.large
					text: Icons.getNotifIcon(root.notifs[0]?.summary, root.urgency)
				}
			}

			ClippingRectangle {
				anchors.fill: parent
				color: root.urgency === "critical" ? DynamicColors.palette.m3error : root.urgency === "low" ? DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 3) : DynamicColors.palette.m3secondaryContainer
				radius: Appearance.rounding.full

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
					color: root.urgency === "critical" ? DynamicColors.palette.m3error : root.urgency === "low" ? DynamicColors.palette.m3surfaceContainerHighest : DynamicColors.palette.m3secondaryContainer
					implicitHeight: Config.notifs.sizes.badge
					implicitWidth: Config.notifs.sizes.badge
					radius: Appearance.rounding.full

					ColoredIcon {
						anchors.centerIn: parent
						color: root.urgency === "critical" ? DynamicColors.palette.m3onError : root.urgency === "low" ? DynamicColors.palette.m3onSurface : DynamicColors.palette.m3onSecondaryContainer
						implicitSize: Math.round(Config.notifs.sizes.badge * 0.6)
						layer.enabled: root.appIcon.endsWith("symbolic")
						source: Quickshell.iconPath(root.appIcon)
					}
				}
			}
		}

		ColumnLayout {
			Layout.bottomMargin: -Appearance.padding.small / 2 - (root.expanded ? 0 : spacing)
			Layout.fillWidth: true
			Layout.topMargin: -Appearance.padding.small
			spacing: Math.round(Appearance.spacing.small / 2)

			RowLayout {
				Layout.bottomMargin: -parent.spacing
				Layout.fillWidth: true
				spacing: Appearance.spacing.smaller

				CustomText {
					Layout.fillWidth: true
					color: DynamicColors.palette.m3onSurfaceVariant
					elide: Text.ElideRight
					font.pointSize: Appearance.font.size.small
					text: root.modelData
				}

				CustomText {
					animate: true
					color: DynamicColors.palette.m3outline
					font.pointSize: Appearance.font.size.small
					text: root.notifs[0]?.timeStr ?? ""
				}

				CustomRect {
					Layout.preferredWidth: root.notifs.length > Config.notifs.groupPreviewNum ? implicitWidth : 0
					color: root.urgency === "critical" ? DynamicColors.palette.m3error : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, 2)
					implicitHeight: groupCount.implicitHeight + Appearance.padding.small
					implicitWidth: expandBtn.implicitWidth + Appearance.padding.smaller * 2
					opacity: root.notifs.length > Config.notifs.groupPreviewNum ? 1 : 0
					radius: Appearance.rounding.full

					Behavior on Layout.preferredWidth {
						Anim {
						}
					}
					Behavior on opacity {
						Anim {
						}
					}

					StateLayer {
						function onClicked(): void {
							root.expanded = !root.expanded;
						}

						color: root.urgency === "critical" ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurface
					}

					RowLayout {
						id: expandBtn

						anchors.centerIn: parent
						spacing: Appearance.spacing.small / 2

						CustomText {
							id: groupCount

							Layout.leftMargin: Appearance.padding.small / 2
							animate: true
							color: root.urgency === "critical" ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurface
							font.pointSize: Appearance.font.size.small
							text: root.notifs.length
						}

						MaterialIcon {
							Layout.rightMargin: -Appearance.padding.small / 2
							animate: true
							color: root.urgency === "critical" ? DynamicColors.palette.m3onError : DynamicColors.palette.m3onSurface
							text: root.expanded ? "expand_less" : "expand_more"
						}
					}
				}
			}

			Repeater {
				model: ScriptModel {
					values: root.notifs.slice(0, Config.notifs.groupPreviewNum)
				}

				NotifLine {
					id: notif

					ParallelAnimation {
						running: true

						Anim {
							from: 0
							property: "opacity"
							target: notif
							to: 1
						}

						Anim {
							from: 0.7
							property: "scale"
							target: notif
							to: 1
						}

						Anim {
							from: 0
							property: "preferredHeight"
							target: notif.Layout
							to: notif.implicitHeight
						}
					}

					ParallelAnimation {
						running: notif.modelData.closed

						onFinished: notif.modelData.unlock(notif)

						Anim {
							property: "opacity"
							target: notif
							to: 0
						}

						Anim {
							property: "scale"
							target: notif
							to: 0.7
						}

						Anim {
							property: "preferredHeight"
							target: notif.Layout
							to: 0
						}
					}
				}
			}

			Loader {
				Layout.fillWidth: true
				Layout.preferredHeight: root.expanded ? implicitHeight : 0
				active: opacity > 0
				opacity: root.expanded ? 1 : 0

				Behavior on opacity {
					Anim {
					}
				}
				sourceComponent: ColumnLayout {
					Repeater {
						model: ScriptModel {
							values: root.notifs.slice(Config.notifs.groupPreviewNum)
						}

						NotifLine {
						}
					}
				}
			}
		}
	}

	component NotifLine: CustomText {
		id: notifLine

		required property NotifServer.Notif modelData

		Layout.fillWidth: true
		color: root.urgency === "critical" ? DynamicColors.palette.m3onSecondaryContainer : DynamicColors.palette.m3onSurface
		text: {
			const summary = modelData.summary.replace(/\n/g, " ");
			const body = modelData.body.replace(/\n/g, " ");
			const color = root.urgency === "critical" ? DynamicColors.palette.m3secondary : DynamicColors.palette.m3outline;

			if (metrics.text === metrics.elidedText)
				return `${summary} <span style='color:${color}'>${body}</span>`;

			const t = metrics.elidedText.length - 3;
			if (t < summary.length)
				return `${summary.slice(0, t)}...`;

			return `${summary} <span style='color:${color}'>${body.slice(0, t - summary.length)}...</span>`;
		}
		textFormat: Text.MarkdownText

		Component.onCompleted: modelData.lock(this)
		Component.onDestruction: modelData.unlock(this)

		TextMetrics {
			id: metrics

			elide: Text.ElideRight
			elideWidth: notifLine.width
			font.family: notifLine.font.family
			font.pointSize: notifLine.font.pointSize
			text: `${notifLine.modelData.summary} ${notifLine.modelData.body}`.replace(/\n/g, " ")
		}
	}
}
