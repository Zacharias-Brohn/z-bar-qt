pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Modules
import qs.Components
import qs.Helpers
import qs.Config
import qs.Daemons

ColumnLayout {
	id: root

	required property var lock

	anchors.fill: parent
	anchors.margins: Appearance.padding.large
	spacing: Appearance.spacing.smaller

	CustomText {
		Layout.fillWidth: true
		color: DynamicColors.palette.m3outline
		elide: Text.ElideRight
		font.family: Appearance.font.family.mono
		font.weight: 500
		text: NotifServer.list.length > 0 ? qsTr("%1 notification%2").arg(NotifServer.list.length).arg(NotifServer.list.length === 1 ? "" : "s") : qsTr("Notifications")
	}

	ClippingRectangle {
		id: clipRect

		Layout.fillHeight: true
		Layout.fillWidth: true
		color: "transparent"
		radius: Appearance.rounding.small

		Loader {
			active: opacity > 0
			anchors.centerIn: parent
			opacity: NotifServer.list.length > 0 ? 0 : 1

			Behavior on opacity {
				Anim {
					duration: Appearance.anim.durations.extraLarge
				}
			}
			sourceComponent: ColumnLayout {
				spacing: Appearance.spacing.large

				Image {
					asynchronous: true
					fillMode: Image.PreserveAspectFit
					layer.enabled: true
					source: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/dino.png`)
					sourceSize.width: clipRect.width * 0.8

					layer.effect: Coloriser {
						brightness: 1
						colorizationColor: DynamicColors.palette.m3outlineVariant
					}
				}

				CustomText {
					Layout.alignment: Qt.AlignHCenter
					color: DynamicColors.palette.m3outlineVariant
					font.family: Appearance.font.family.mono
					font.pointSize: Appearance.font.size.large
					font.weight: 500
					text: qsTr("No Notifications")
				}
			}
		}

		CustomListView {
			anchors.fill: parent
			clip: true
			spacing: Appearance.spacing.small

			add: Transition {
				Anim {
					from: 0
					property: "opacity"
					to: 1
				}

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					from: 0
					property: "scale"
					to: 1
				}
			}
			delegate: NotifGroup {
			}
			displaced: Transition {
				Anim {
					properties: "opacity,scale"
					to: 1
				}

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					property: "y"
				}
			}
			model: ScriptModel {
				values: {
					const list = NotifServer.notClosed.map(n => [n.appName, null]);
					return [...new Map(list).keys()];
				}
			}
			move: Transition {
				Anim {
					properties: "opacity,scale"
					to: 1
				}

				Anim {
					duration: Appearance.anim.durations.expressiveDefaultSpatial
					easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
					property: "y"
				}
			}
			remove: Transition {
				Anim {
					property: "opacity"
					to: 0
				}

				Anim {
					property: "scale"
					to: 0.6
				}
			}
		}
	}
}
