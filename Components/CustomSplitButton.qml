import QtQuick
import QtQuick.Layouts
import qs.Config

Row {
	id: root

	enum Type {
		Filled,
		Tonal
	}

	property alias active: menu.active
	property color color: type == CustomSplitButton.Filled ? DynamicColors.palette.m3primary : DynamicColors.palette.m3secondaryContainer
	property bool disabled
	property color disabledColor: Qt.alpha(DynamicColors.palette.m3onSurface, 0.1)
	property color disabledTextColor: Qt.alpha(DynamicColors.palette.m3onSurface, 0.38)
	property alias expanded: menu.expanded
	property string fallbackIcon
	property string fallbackText
	property real horizontalPadding: Appearance.padding.normal
	property alias iconLabel: iconLabel
	property alias label: label
	property alias menu: menu
	property alias menuItems: menu.items
	property bool menuOnTop
	property alias stateLayer: stateLayer
	property color textColor: type == CustomSplitButton.Filled ? DynamicColors.palette.m3onPrimary : DynamicColors.palette.m3onSecondaryContainer
	property int type: CustomSplitButton.Filled
	property real verticalPadding: Appearance.padding.smaller

	spacing: Math.floor(Appearance.spacing.small / 2)

	CustomRect {
		bottomRightRadius: Appearance.rounding.small / 2
		color: root.disabled ? root.disabledColor : root.color
		implicitHeight: expandBtn.implicitHeight
		implicitWidth: textRow.implicitWidth + root.horizontalPadding * 2
		radius: implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
		topRightRadius: Appearance.rounding.small / 2

		StateLayer {
			id: stateLayer

			function onClicked(): void {
				root.active?.clicked();
			}

			color: root.textColor
			disabled: root.disabled
			rect.bottomRightRadius: parent.bottomRightRadius
			rect.topRightRadius: parent.topRightRadius
		}

		RowLayout {
			id: textRow

			anchors.centerIn: parent
			anchors.horizontalCenterOffset: Math.floor(root.verticalPadding / 4)
			spacing: Appearance.spacing.small

			MaterialIcon {
				id: iconLabel

				Layout.alignment: Qt.AlignVCenter
				animate: true
				color: root.disabled ? root.disabledTextColor : root.textColor
				fill: 1
				text: root.active?.activeIcon ?? root.fallbackIcon
			}

			CustomText {
				id: label

				Layout.alignment: Qt.AlignVCenter
				Layout.preferredWidth: implicitWidth
				animate: true
				clip: true
				color: root.disabled ? root.disabledTextColor : root.textColor
				text: root.active?.activeText ?? root.fallbackText

				Behavior on Layout.preferredWidth {
					Anim {
						easing.bezierCurve: Appearance.anim.curves.emphasized
					}
				}
			}
		}
	}

	CustomRect {
		id: expandBtn

		property real rad: root.expanded ? implicitHeight / 2 * Math.min(1, Appearance.rounding.scale) : Appearance.rounding.small / 2

		bottomLeftRadius: rad
		color: root.disabled ? root.disabledColor : root.color
		implicitHeight: expandIcon.implicitHeight + root.verticalPadding * 2
		implicitWidth: implicitHeight
		radius: implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
		topLeftRadius: rad

		Behavior on rad {
			Anim {
			}
		}

		StateLayer {
			id: expandStateLayer

			function onClicked(): void {
				root.expanded = !root.expanded;
			}

			color: root.textColor
			disabled: root.disabled
			rect.bottomLeftRadius: parent.bottomLeftRadius
			rect.topLeftRadius: parent.topLeftRadius
		}

		MaterialIcon {
			id: expandIcon

			anchors.centerIn: parent
			anchors.horizontalCenterOffset: root.expanded ? 0 : -Math.floor(root.verticalPadding / 4)
			color: root.disabled ? root.disabledTextColor : root.textColor
			rotation: root.expanded ? 180 : 0
			text: "expand_more"

			Behavior on anchors.horizontalCenterOffset {
				Anim {
				}
			}
			Behavior on rotation {
				Anim {
				}
			}
		}

		Menu {
			id: menu

			anchors.bottomMargin: Appearance.spacing.small
			anchors.right: parent.right
			anchors.top: parent.bottom
			anchors.topMargin: Appearance.spacing.small

			states: State {
				when: root.menuOnTop

				AnchorChanges {
					anchors.bottom: expandBtn.top
					anchors.top: undefined
					target: menu
				}
			}
		}
	}
}
