import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Components
import qs.Config

Item {
	id: root

	property color borderColor: warning ? DynamicColors.palette.m3onError : mainColor
	required property color mainColor
	required property double percentage
	property bool shown: true
	property color usageColor: warning ? DynamicColors.palette.m3error : mainColor
	property bool warning: percentage * 100 >= warningThreshold
	property int warningThreshold: 100

	clip: true
	implicitHeight: 22
	implicitWidth: resourceRowLayout.x < 0 ? 0 : resourceRowLayout.implicitWidth
	visible: width > 0 && height > 0

	Behavior on percentage {
		NumberAnimation {
			duration: 300
			easing.type: Easing.InOutQuad
		}
	}

	RowLayout {
		id: resourceRowLayout

		spacing: 2
		x: shown ? 0 : -resourceRowLayout.width

		anchors {
			verticalCenter: parent.verticalCenter
		}

		Item {
			Layout.alignment: Qt.AlignVCenter
			implicitHeight: root.implicitHeight
			implicitWidth: 14

			Rectangle {
				id: backgroundCircle

				anchors.centerIn: parent
				border.color: "#404040"
				border.width: 1
				color: "#40000000"
				height: 14
				radius: height / 2
				width: 14
			}

			Shape {
				anchors.fill: backgroundCircle
				preferredRendererType: Shape.CurveRenderer
				smooth: true

				ShapePath {
					fillColor: root.usageColor
					startX: backgroundCircle.width / 2
					startY: backgroundCircle.height / 2
					strokeWidth: 0

					Behavior on fillColor {
						CAnim {
						}
					}

					PathLine {
						x: backgroundCircle.width / 2
						y: 0 + (1 / 2)
					}

					PathAngleArc {
						centerX: backgroundCircle.width / 2
						centerY: backgroundCircle.height / 2
						radiusX: backgroundCircle.width / 2 - (1 / 2)
						radiusY: backgroundCircle.height / 2 - (1 / 2)
						startAngle: -90
						sweepAngle: 360 * root.percentage
					}

					PathLine {
						x: backgroundCircle.width / 2
						y: backgroundCircle.height / 2
					}
				}

				ShapePath {
					capStyle: ShapePath.FlatCap
					fillColor: "transparent"
					strokeColor: root.borderColor
					strokeWidth: 1

					Behavior on strokeColor {
						CAnim {
						}
					}

					PathAngleArc {
						centerX: backgroundCircle.width / 2
						centerY: backgroundCircle.height / 2
						radiusX: backgroundCircle.width / 2 - (1 / 2)
						radiusY: backgroundCircle.height / 2 - (1 / 2)
						startAngle: -90
						sweepAngle: 360 * root.percentage
					}
				}
			}
		}
	}
}
