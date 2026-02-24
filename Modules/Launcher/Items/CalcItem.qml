import ZShell
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Modules
import qs.Helpers
import qs.Config

Item {
	id: root

	required property var list
	readonly property string math: list.search.text.slice(`${Config.launcher.actionPrefix}calc `.length)

	function onClicked(): void {
		Quickshell.execDetached(["wl-copy", Qalculator.eval(math, false)]);
		root.list.visibilities.launcher = false;
	}

	anchors.left: parent?.left
	anchors.right: parent?.right
	implicitHeight: Config.launcher.sizes.itemHeight

	StateLayer {
		function onClicked(): void {
			root.onClicked();
		}

		radius: Appearance.rounding.normal
	}

	RowLayout {
		anchors.left: parent.left
		anchors.margins: Appearance.padding.larger
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		spacing: Appearance.spacing.normal

		MaterialIcon {
			Layout.alignment: Qt.AlignVCenter
			font.pointSize: Appearance.font.size.extraLarge
			text: "function"
		}

		CustomText {
			id: result

			Layout.alignment: Qt.AlignVCenter
			Layout.fillWidth: true
			color: {
				if (text.includes("error: ") || text.includes("warning: "))
					return DynamicColors.palette.m3error;
				if (!root.math)
					return DynamicColors.palette.m3onSurfaceVariant;
				return DynamicColors.palette.m3onSurface;
			}
			elide: Text.ElideLeft
			text: root.math.length > 0 ? Qalculator.eval(root.math) : qsTr("Type an expression to calculate")
		}

		CustomRect {
			Layout.alignment: Qt.AlignVCenter
			clip: true
			color: DynamicColors.palette.m3tertiary
			implicitHeight: Math.max(label.implicitHeight, icon.implicitHeight) + Appearance.padding.small * 2
			implicitWidth: (stateLayer.containsMouse ? label.implicitWidth + label.anchors.rightMargin : 0) + icon.implicitWidth + Appearance.padding.normal * 2
			radius: Appearance.rounding.normal

			Behavior on implicitWidth {
				Anim {
					easing.bezierCurve: Appearance.anim.curves.expressiveEffects
				}
			}

			StateLayer {
				id: stateLayer

				function onClicked(): void {
					Quickshell.execDetached(["app2unit", "--", ...Config.general.apps.terminal, "fish", "-C", `exec qalc -i '${root.math}'`]);
					root.list.visibilities.launcher = false;
				}

				color: DynamicColors.palette.m3onTertiary
			}

			CustomText {
				id: label

				anchors.right: icon.left
				anchors.rightMargin: Appearance.spacing.small
				anchors.verticalCenter: parent.verticalCenter
				color: DynamicColors.palette.m3onTertiary
				font.pointSize: Appearance.font.size.normal
				opacity: stateLayer.containsMouse ? 1 : 0
				text: qsTr("Open in calculator")

				Behavior on opacity {
					Anim {
					}
				}
			}

			MaterialIcon {
				id: icon

				anchors.right: parent.right
				anchors.rightMargin: Appearance.padding.normal
				anchors.verticalCenter: parent.verticalCenter
				color: DynamicColors.palette.m3onTertiary
				font.pointSize: Appearance.font.size.large
				text: "open_in_new"
			}
		}
	}
}
