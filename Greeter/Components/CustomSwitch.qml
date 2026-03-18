import QtQuick
import QtQuick.Templates
import QtQuick.Shapes
import qs.Config

Switch {
	id: root

	property int cLayer: 1

	implicitHeight: implicitIndicatorHeight
	implicitWidth: implicitIndicatorWidth

	indicator: CustomRect {
		color: root.checked ? DynamicColors.palette.m3primary : DynamicColors.layer(DynamicColors.palette.m3surfaceContainerHighest, root.cLayer)
		implicitHeight: 13 + 7 * 2
		implicitWidth: implicitHeight * 1.7
		radius: 1000

		CustomRect {
			readonly property real nonAnimWidth: root.pressed ? implicitHeight * 1.3 : implicitHeight

			anchors.verticalCenter: parent.verticalCenter
			color: root.checked ? DynamicColors.palette.m3onPrimary : DynamicColors.layer(DynamicColors.palette.m3outline, root.cLayer + 1)
			implicitHeight: parent.implicitHeight - 10
			implicitWidth: nonAnimWidth
			radius: 1000
			x: root.checked ? parent.implicitWidth - nonAnimWidth - 10 / 2 : 10 / 2

			Behavior on implicitWidth {
				Anim {
				}
			}
			Behavior on x {
				Anim {
				}
			}

			CustomRect {
				anchors.fill: parent
				color: root.checked ? DynamicColors.palette.m3primary : DynamicColors.palette.m3onSurface
				opacity: root.pressed ? 0.1 : root.hovered ? 0.08 : 0
				radius: parent.radius

				Behavior on opacity {
					Anim {
					}
				}
			}

			Shape {
				id: icon

				property point end1: {
					if (root.pressed) {
						if (root.checked)
							return Qt.point(width * 0.4, height / 2);
						return Qt.point(width * 0.8, height / 2);
					}
					if (root.checked)
						return Qt.point(width * 0.4, height * 0.7);
					return Qt.point(width * 0.85, height * 0.85);
				}
				property point end2: {
					if (root.pressed)
						return Qt.point(width, height / 2);
					if (root.checked)
						return Qt.point(width * 0.85, height * 0.2);
					return Qt.point(width * 0.85, height * 0.15);
				}
				property point start1: {
					if (root.pressed)
						return Qt.point(width * 0.1, height / 2);
					if (root.checked)
						return Qt.point(width * 0.15, height / 2);
					return Qt.point(width * 0.15, height * 0.15);
				}
				property point start2: {
					if (root.pressed) {
						if (root.checked)
							return Qt.point(width * 0.4, height / 2);
						return Qt.point(width * 0.2, height / 2);
					}
					if (root.checked)
						return Qt.point(width * 0.4, height * 0.7);
					return Qt.point(width * 0.15, height * 0.85);
				}

				anchors.centerIn: parent
				asynchronous: true
				height: parent.implicitHeight - Appearance.padding.small * 2
				preferredRendererType: Shape.CurveRenderer
				width: height

				Behavior on end1 {
					PropAnim {
					}
				}
				Behavior on end2 {
					PropAnim {
					}
				}
				Behavior on start1 {
					PropAnim {
					}
				}
				Behavior on start2 {
					PropAnim {
					}
				}

				ShapePath {
					capStyle: Appearance.rounding.scale === 0 ? ShapePath.SquareCap : ShapePath.RoundCap
					fillColor: "transparent"
					startX: icon.start1.x
					startY: icon.start1.y
					strokeColor: root.checked ? DynamicColors.palette.m3primary : DynamicColors.palette.m3surfaceContainerHighest
					strokeWidth: Appearance.font.size.larger * 0.15

					Behavior on strokeColor {
						CAnim {
						}
					}

					PathLine {
						x: icon.end1.x
						y: icon.end1.y
					}

					PathMove {
						x: icon.start2.x
						y: icon.start2.y
					}

					PathLine {
						x: icon.end2.x
						y: icon.end2.y
					}
				}
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		enabled: false
	}

	component PropAnim: PropertyAnimation {
		duration: MaterialEasing.expressiveEffectsTime
		easing.bezierCurve: MaterialEasing.expressiveEffects
		easing.type: Easing.BezierSpline
	}
}
